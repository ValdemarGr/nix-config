{
  description = "Valde's nixos configuration";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixpkgs.services.xserver = {
      enabled = true;
      displayManager = {
        defaultSession = "none+i3";
      };
      windowMaanger.i3 = {
        enable = true;
      };
    };
  };
}