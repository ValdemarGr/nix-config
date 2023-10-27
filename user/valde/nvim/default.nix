inputs:

{ lib, pkgs, ... }:

let
  metals-version = "1.0.1";
  vim-init = builtins.readFile ./init.vim;
  lua-files = [
    ./telescope.lua
    ./cmp.lua
    #./tree.lua
    ./oil.lua
  ];
  lua-file-contents =
    lib.lists.map
      (x: builtins.readFile x)
      lua-files
  ;
  metals-deps = pkgs.stdenv.mkDerivation {
    name = "metals-deps-${metals-version}";
    buildCommand = ''
          export COURSIER_CACHE=$(pwd)
          ${pkgs.coursier}/bin/cs fetch org.scalameta:metals_2.13:${metals-version} \
      -r bintray:scalacenter/releases \
      -r sonatype:snapshots > deps
          mkdir -p $out/share/java
          cp -n $(< deps) $out/share/java/
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-AamUE6mr9fwjbDndQtzO2Yscu2T6zUW/DiXMYwv35YE=";
  };
  telescope-fzf-native-plugin = pkgs.stdenv.mkDerivation {
    name = "telescope-fzf-native-plugin";
    src = inputs.telescope-fzf-native;
    buildPhase = ''
      	  make
      	  '';
    installPhase = ''
      	    mkdir $out
      	    cp -r * $out/
      	  '';
  };
  metals-pkg = pkgs.metals.overrideAttrs (old: {
    version = metals-version;
    extraJavaOpts = old.extraJavaOpts + " -Dmetals.client=nvim-lsp";
    buildInputs = [ metals-deps ];
  });
  vim-plugin-keys = lib.lists.filter
    (key: lib.strings.hasSuffix "-plugin" key)
    (lib.attrNames inputs)
  ;
  vim-plugins = [ telescope-fzf-native-plugin ] ++ (lib.lists.map
    (key: (pkgs.vimUtils.buildVimPlugin {
      pname = key;
      src = inputs."${key}";
      version = "0.1";
    }))
    vim-plugin-keys)
  ;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = vim-plugins ++ [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
    extraConfig = vim-init + ''

    let g:copilot_node_command = "${pkgs.nodejs_18}/bin/node"
    '';
    extraLuaConfig = (lib.strings.concatLines lua-file-contents) + ''

    require('harpoon').setup()
    require('hop').setup()
    require('octo').setup()
    require('lspconfig').terraformls.setup{}
    require('lspconfig').graphql.setup{}

    vim.opt_global.shortmess:remove("F")

    metals_config = require('metals').bare_config()
    metals_config.init_options.statusBarProvider = "on"
    metals_config.settings = {
      showImplicitArguments = true,
      enableSemanticHighlighting = false,
      metalsBinaryPath = "${metals-pkg}/bin/metals"
    }

    vim.cmd [[augroup lsp]]
    vim.cmd [[au!]]
    vim.cmd [[au FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)]]
    vim.cmd [[augroup end]]

    vim.cmd([[hi! link LspReferenceText CursorColumn]])
    vim.cmd([[hi! link LspReferenceRead CursorColumn]])
    vim.cmd([[hi! link LspReferenceWrite CursorColumn]])

    require("nvim-treesitter.configs").setup{
      highlight = {
        enable = true
      }
    }

    require('lspconfig').rescriptls.setup{
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      cmd = {
        '${pkgs.nodejs_20}/bin/node',
        '${inputs.vim-rescript-plugin}/server/out/server.js',
        '--stdio'
      }
    }
    '';
  };
}
