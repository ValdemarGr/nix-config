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
	      nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
	    ./system/machine/home
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
	      nixpkgs.config.allowUnfree = true;
                users.users.${machine} = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" "video" "audio" ];
                };
			hardware.opengl = {
				enable = true;
				driSupport = true;
				driSupport32Bit = true;
			};
	    security.polkit.enable = true;
	    programs.sway.enable = true;
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${machine} = {
                    home.packages = [pkgs.gh];
#		  wayland.windowManager.sway.enable = true;
		    wayland.windowManager.hyprland.enable = true;
		    wayland.windowManager.hyprland.xwayland.enable = true;
		    wayland.windowManager.hyprland.extraConfig = ''
		      $mod = SUPER
		      bind = $mod, F, exec, kitty
		    '';
		    home  = {
		    	pointerCursor = {
				gtk.enable = true;
				package = pkgs.bibata-cursors;
				name = "Bibata-Modern-Amber";
				size = 32;
			};
		    };
                    home.stateVersion = "23.05";
                    home.username = "${machine}";
                    home.homeDirectory = "/home/${machine}";
		    gtk = {
		    	enable = true;
			theme = {
				package = pkgs.flat-remix-gtk;
				name = "Flat-Remix-GTK-Grey-Darkest";
			};
			iconTheme = {
				package = pkgs.libsForQt5.breeze-icons;
				name = "breeze-dark";
			};
			font = {
				name = "Sans";
				size = 11;
			};
		    };
                    programs.home-manager.enable = true;
                    programs.bash.enable = true;
		    programs.kitty.enable = true;
		    programs.rofi.enable = true;
		    services.spotifyd.enable = true;
		    programs.firefox.enable = true;
		    wayland.windowManager.sway.enable = true;
                    programs.git = {
		      enable = true;
		      userName = "Valdemar Grange";
		      userEmail = "randomvald0069@gmail.com";
		    };
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
                environment.systemPackages = [pkgs.gh pkgs.spotify pkgs.dunst];
		sound.enable = true;
		security.rtkit.enable = true;
		services.pipewire = {
		  enable = true;
		  alsa.enable = true;
		  alsa.support32Bit = true;
		  pulse.enable = true;
		  jack.enable = true;
		};
		#programs.hyprland.enable = true;
                programs.git.enable = true;
                programs.neovim.enable = true;
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
