inputs:

{ lib, pkgs, ... }:

let
  metals-version = "1.6.5";
  # metals-version = "2.0.0-M7";
  metals-pkg = pkgs.stdenv.mkDerivation (finalAttrs: {
    name = "metals";
    version = metals-version;

    deps = pkgs.stdenv.mkDerivation {
      name = "metals-deps";
      version = metals-version;
      buildCommand = ''
        export COURSIER_CACHE=$(pwd)
        mkdir -p $out/bin
        ${pkgs.coursier}/bin/cs bootstrap org.scalameta:metals_2.13:${metals-version} \
          -r bintray:scalacenter/releases \
          -r sonatype:snapshots \
          --repository "https://central.sonatype.com/repository/maven-snapshots" \
          --standalone \
          -o $out/bin/metals-launcher
      '';
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-XQFoPMhj2demLM1WWBaxNt/rPE14DgYZOhx+5ue6XP0=";
      # outputHash = "sha256-tUetJ4v+6DJyJGMuiMQthVI4HrJOl8FEL90cI29l1l8=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ finalAttrs.deps ];
    dontUnpack = true;
    extraJavaOpts = 
      "-XX:+UseG1GC" +
      "-XX:+UseStringDeduplication" +
      "-Xss4m" +
      "-Xms100m" +
      "-Dmetals.client=nvim-lsp" +
      "-Dmetals.verbose=true" +
      "-Dmetals.askToReconnect=false" +
      "-Dmetals.loglevel=debug" +
      "-Dmetals.build-server-ping-interval=10h";

    installPhase = ''
      mkdir -p $out/bin

      makeWrapper ${finalAttrs.deps}/bin/metals-launcher $out/bin/metals \
        --set JAVA_HOME ${pkgs.jre} --add-flags ${finalAttrs.extraJavaOpts}
    '';
  });
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
    ${pkgs.nodejs_20}/bin/node ${rescript-npm-pkg}/out/cli.js --stdio
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
      doCheck = false;
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
      node = '${pkgs.nodejs_20}/bin/node',
      rust_analyzer = 'rust-analyzer',
      ts_ls = '${pkgs.typescript-language-server}/bin/typescript-language-server',
    }
    '';
  };
}
