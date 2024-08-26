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
    vim-fugitive-plugin = {
      url = "github:tpope/vim-fugitive/cbe9dfa162c178946afa689dd3f42d4ea8bf89c1";
      flake = false;
    };
    gruvbox-baby-plugin = {
      url = "github:valdemargr/gruvbox-baby/d005d431de5343ea7640d1c3b57570c89f992ac4";
      flake = false;
    };
    nvim-metals-plugin = {
      url = "github:scalameta/nvim-metals/1b87e6bfa4174b5fbaee9ca7ec79d8eae8df7f18";
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
    telescope-live-grep-args-plugin = {
      url = "github:nvim-telescope/telescope-live-grep-args.nvim";
      flake = false;
    };
    vim-surround-plugin = {
      url = "github:tpope/vim-surround";
      flake = false;
    };
    vim-commentary-plugin = {
      url = "github:tpope/vim-commentary";
      flake = false;
    };
    nvim-tree-plugin = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };
    pgsql-plugin = {
      url = "github:lifepillar/pgsql.vim";
      flake = false;
    };
    vim-terraform-plugin = {
      url = "github:hashivim/vim-terraform";
      flake = false;
    };
    vim-lastplace-plugin = {
      url = "github:farmergreg/vim-lastplace";
      flake = false;
    };
    vim-devicons-plugin = {
      url = "github:ryanoasis/vim-devicons";
      flake = false;
    };
    popup-plugin = {
      url = "github:nvim-lua/popup.nvim";
      flake = false;
    };
    telescope-fzf-native = {
      url = "github:nvim-telescope/telescope-fzf-native.nvim";
      flake = false;
    };
    nvim-web-devicons-plugin = {
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    nvim-lspconfig-plugin = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    hop-plugin = {
      url = "github:phaazon/hop.nvim";
      flake = false;
    };
    nvim-cmp-plugin = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-buffer-plugin = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-path-plugin = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-git-plugin = {
      url = "github:petertriho/cmp-git";
      flake = false;
    };
    cmp-nvim-lsp-plugin = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-nvim-lsp-signature-help-plugin = {
      url = "github:hrsh7th/cmp-nvim-lsp-signature-help";
      flake = false;
    };
    cmp-calc-plugin = {
      url = "github:hrsh7th/cmp-calc";
      flake = false;
    };
    cmp-copilot-plugin = {
      url = "github:hrsh7th/cmp-copilot";
      flake = false;
    };
    cmp-treesitter-plugin = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };
    playground-plugin = {
      url = "github:nvim-treesitter/playground";
      flake = false;
    };
    vim-rescript-plugin = {
      url = "github:rescript-lang/vim-rescript/2065f4e1d319ffd4ff7046879f270ebbadda873e";
      flake = false;
    };
    vim-harpoon-plugin = {
      url = "github:ThePrimeagen/harpoon/master";
      flake = false;
    };
    copilot-vim-plugin = {
      url = "github:github/copilot.vim";
      flake = false;
    };
    octo-plugin = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    oil-nvim-plugin = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    leap-nvim-plugin = {
      url = "github:ggandor/leap.nvim";
      flake = false;
    };
    gke-auth-module = {
      flake = false;
      url = "github:traviswt/gke-auth-plugin";
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
    };
}
