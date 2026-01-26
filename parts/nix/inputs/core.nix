{
  ...
}:
{
  # Base inputs for the NiXOA system flake.
  flake-file.inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixoaCore = {
      url = "git+https://codeberg.org/NiXOA/core?ref=beta";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    snitch = {
      url = "github:karol-broda/snitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
