inputs:

{ lib, pkgs, ... }:

let
  metals-version = "1.1.0";
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
    outputHash = "sha256-9zigJM0xEJSYgohbjc9ZLBKbPa/WGVSv3KVFE3QUzWE=";
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
    extraJavaOpts = old.extraJavaOpts + 
      " -Dmetals.client=nvim-lsp" +
      " -Dmetals.verbose=true" +
      " -Dmetals.askToReconnect=false" +
      " -Dmetals.loglevel=debug" +
      " -Dmetals.build-server-ping-interval=10h";
    buildInputs = [ metals-deps ];
    installPhase = ''
      mkdir -p $out/bin

      makeWrapper ${pkgs.jdk11}/bin/java $out/bin/metals \
        --add-flags "$extraJavaOpts -cp $CLASSPATH scala.meta.metals.Main"
    '';
  });
  rescript-lsp-start = pkgs.writeShellScriptBin "rescript-lsp-start" ''
    ${pkgs.nodejs_18}/bin/node ${inputs.vim-rescript-plugin}/server/out/server.js --stdio
  '';
  rescript-lsp-fhs = pkgs.buildFHSEnv {
    name = "rescript-lsp-fhs";
    runScript = "rescript-lsp-start";
    targetPkgs = pkgs: [
      rescript-lsp-start
    ];
  };
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
  home.file.".vimtmp" = {
    recursive = true;
    target = ".vimtmp/keep";
    source = builtins.toFile "keep" ""; 
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = vim-plugins ++ [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
    extraConfig = vim-init + ''

    let g:copilot_node_command = "${pkgs.nodejs_18}/bin/node"
    let g:copilot_filetypes = {
      \ '*': v:true,
    \ }
    '';
    extraLuaConfig = (lib.strings.concatLines lua-file-contents) + ''

    -- require('hop').setup()
    require('leap')
    -- require('leap').add_default_mappings()
    vim.keymap.set({ "n" }, "<leader>M", "<Plug>(leap-backward-to)")
    vim.keymap.set({ "n" }, "<leader>m", "<Plug>(leap-forward-to)")

    vim.keymap.set({ "n" }, "`", "'", { noremap = true })
    vim.keymap.set({ "n" }, "'", "`", { noremap = true })

    require('octo').setup()
    require('lspconfig').terraformls.setup{
      cmd = { "${pkgs.terraform-ls}/bin/terraform-ls", "serve" }
    }
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

    vim.cmd [[augroup Authzed]]
    vim.cmd [[au!]]
    vim.cmd [[autocmd BufNewFile,BufRead *.authzed set filetype=authzed]]
    vim.cmd [[autocmd BufNewFile,BufRead *.zed set filetype=authzed]]
    vim.cmd [[autocmd BufNewFile,BufRead *.azd set filetype=authzed]]
    vim.cmd [[augroup end]]

    vim.keymap.set("n", "<leader>.", function() require("harpoon.mark").add_file() end)
    vim.keymap.set("n", "<leader>,", function() require("harpoon.ui").toggle_quick_menu() end)

    vim.keymap.set("n", "<C-h>", function() require("harpoon.ui").nav_file(1) end)
    vim.keymap.set("n", "<C-t>", function() require("harpoon.ui").nav_file(2) end)
    vim.keymap.set("n", "<C-n>", function() require("harpoon.ui").nav_file(3) end)
    vim.keymap.set("n", "<C-s>", function() require("harpoon.ui").nav_file(4) end)

    require('lspconfig').rescriptls.setup{
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      cmd = {
        '${rescript-lsp-fhs}/bin/rescript-lsp-fhs'
      }
    }
    '';
  };
}
