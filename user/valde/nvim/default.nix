inputs:

{ lib, pkgs, ...}:

let
  metals-version = "1.1.0";
  vim-init = builtins.readFile ./init.vim;
  lua-files = [
    ./telescope.lua
    ./metals.lua
    ./tree.lua
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
          extraJavaOpts = old.extraJavaOpts + " -Dmetals.client=nvim-lsp";
          buildInputs = [ metals-deps ];
        });
        vim-plugin-keys = lib.lists.filter
          (key: lib.strings.hasSuffix "-plugin" key)
          (lib.attrNames inputs)
        ;
        vim-plugins = [telescope-fzf-native-plugin] ++ (lib.lists.map
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
    plugins = vim-plugins;
    extraConfig = vim-init;
    extraLuaConfig = lib.strings.concatLines lua-file-contents;
  };
}
