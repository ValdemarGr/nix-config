inputs:

{ lib, pkgs, ... }:

let
  metals-version = "1.3.2";
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
    outputHash = "sha256-hRESY7TFxUjEkNf0vhCG30mIHZHXoAyZl3nTQ3OvQ0E=";
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
  rescript-npm-pkg = pkgs.stdenv.mkDerivation {
    name = "rescript-npm-pkg";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@rescript/language-server/-/language-server-1.50.0.tgz";
      sha256 = "sha256-YK+i8Fay54uhEpRWaOwyxXTgeuSFntKjicMHTlyR6Uc=";
    };
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  #rescript-npm-pkg-fhs = pkgs.buildFHSEnv {
  #  name = "rescript-npm-pkg-fhs";
  #  runScript = "${pkgs.nodejs_18}/bin/node ${rescript-npm-pkg} --stdio";
  #};
  rescript-lsp-start = pkgs.writeShellScriptBin "rescript-lsp-start" ''
    ${pkgs.nodejs_18}/bin/node ${rescript-npm-pkg}/out/cli.js --stdio
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
    extraLuaConfig = ''

    package.path = package.path .. ";${./lua}/?.lua"
    setup = require("config/main")
    setup{
      terraform_ls = '${pkgs.terraform-ls}/bin/terraform-ls',
      metals = '${metals-pkg}/bin/metals',
      rescript_lsp = '${rescript-lsp-fhs}/bin/rescript-lsp-fhs',
      node = '${pkgs.nodejs_18}/bin/node'
    }
    '';
  };
}
