{
  description = "Valde's nixos configuration";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
    	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }: 
    let 
      system = flake-utils.lib.system.x86_64-linux;
      machine = "valde";
    in {
      nixosConfigurations.virtualBox = nixpkgs.lib.nixosSystem {
	inherit system;
	modules = [
		(nixpkgs + "/nixos/modules/installer/virtualbox-demo.nix")
		home-manager.nixosModules.home-manager
		({pkgs, ...}: {
			users.users.${machine} = {
				isNormalUser = true;
				extraGroup = [ "wheel" ];
			};
 			environment.systemPackages = [pkgs.gh];
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
