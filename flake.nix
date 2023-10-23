{
  description = "Valde's nixos configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rofi-unicode-list = {
      url = "github:akhiljalagam/rofi-fontawesome";
      flake = false;
    };
    nvim-telescope-plugin = {
      url = "github:nvim-telescope/telescope.nvim/7011eaae0ac1afe036e30c95cf80200b8dc3f21a";
      flake = false;
    };
    vim-fugitive-plugin = {
      url = "github:tpope/vim-fugitive/cbe9dfa162c178946afa689dd3f42d4ea8bf89c1";
      flake = false;
    };
    gruvbox-baby-plugin = {
      url = "github:valdemargr/gruvbox-baby/f65fe30691db64e8ca32aa6fba0cf07703adca28";
      flake = false;
    };
    nvim-metals-plugin = {
      url = "github:scalameta/nvim-metals/dfcb4f5d915fbc98e6b9b910fbe975b2fbda3227";
      flake = false;
    };
    plenary-plugin = {
      url = "github:nvim-lua/plenary.nvim/50012918b2fc8357b87cff2a7f7f0446e47da174";
      flake = false;
    };
    vim-rhubarb-plugin = {
      url = "github:tpope/vim-rhubarb/ee69335de176d9325267b0fd2597a22901d927b1";
      flake = false;
    };
    undotree-plugin = {
      url = "github:mbbill/undotree/0e11ba7325efbbb3f3bebe06213afa3e7ec75131";
      flake = false;
    };
    sql-plugin = {
     url = "github:tami5/sql.nvim";
     flake = false;
    };
    telescope-nvim-plugin = {
	    url = "github:nvim-telescope/telescope.nvim";
	    flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, rofi-unicode-list, ... }@inputs:
    let
      system = flake-utils.lib.system.x86_64-linux;
      machine = "valde";
      mkSystem = name: import ./lib/mksystem.nix {
        inherit nixpkgs inputs name;
      };
    in
    {
      nixosConfigurations.home = mkSystem "home";
      nixosConfigurations.work = mkSystem "work";
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
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
