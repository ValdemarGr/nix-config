{
  description = "Valde's nixos configuration";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-telescope = {
      url = "github:nvim-telescope/telescope.nvim/7011eaae0ac1afe036e30c95cf80200b8dc3f21a";
      flake = false;
    };
    vim-fugitive = {
      url = "github:tpope/vim-fugitive/cbe9dfa162c178946afa689dd3f42d4ea8bf89c1";
      flake = false;
    };
    gruvbox-baby = {
      url = "github:valdemargr/gruvbox-baby/f65fe30691db64e8ca32aa6fba0cf07703adca28";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, nvim-telescope, vim-fugitive, gruvbox-baby }: 
    let 
      system = flake-utils.lib.system.x86_64-linux;
      machine = "valde";
    in {
	      nixosConfigurations.virtualBox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (nixpkgs + "/nixos/modules/installer/virtualbox-demo.nix")
            home-manager.nixosModules.home-manager
            ({pkgs, ...}: 
              let 
                nvim-telescope-plugin = pkgs.vimUtils.buildVimPlugin {
                  pname = "telescope.nvim";
                  src = nvim-telescope;
                  version = "0.1.4";
                };
                vim-fugitive-plugin = pkgs.vimUtils.buildVimPlugin {
                  pname = "vim-fugitive";
                  src = vim-fugitive;
                  version = "3.1";
                };
                gruvbox-baby-plugin = pkgs.vimUtils.buildVimPlugin {
                  pname = "gruvbox-baby";
                  src = gruvbox-baby;
                  version = "0.1";
                };
              in {
                users.users.${machine} = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                };
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${machine} = {
		  #wayland.windowManager.hyprland.enable = true;
                    home.packages = [pkgs.gh];
#		  wayland.windowManager.sway.enable = true;
		    wayland.windowManager.hyprland.enable = true;
                    home.stateVersion = "23.05";
                    home.username = "${machine}";
                    home.homeDirectory = "/home/${machine}";
                    programs.home-manager.enable = true;
                    programs.bash.enable = true;
                    programs.git.enable = true;
                    programs.neovim = {
                      enable = true;
                      defaultEditor = true;
                      plugins = [
                        nvim-telescope-plugin
                        vim-fugitive-plugin
                        gruvbox-baby-plugin
                      ];
                      extraConfig = ''
                        set number relativenumber
                      '';
                    };
                  };
                };
                environment.systemPackages = [pkgs.gh];
		programs.hyprland.enable = true;
                programs.git.enable = true;
                programs.neovim.enable = true;
              })
          ];
      };
      nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ pkgs, ...}: {
          })
        ];
      };
      # use mkShell
      devShells.${system}.${machine} = nixpkgs.legacyPackages.${system}.pkgs.mkShell {
        name = "hoy";
        buildInputs = [
          nixpkgs.legacyPackages.${system}.pkgs.curl
        ];
        shellHook = ''
          echo "Ohoy!"
        '';
    };
  };
}
