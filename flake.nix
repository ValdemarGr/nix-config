{
  description = "Valde's nixos configuration";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    let 
      system = flake-utils.lib.system.x86_64-linux;
      machine = "valde";
    in {
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
