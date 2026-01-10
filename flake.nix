{
  description = "inlinefun's nix packages flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      eden = import ./packages/eden/package.nix {
        inherit pkgs;
        cacheBuilds = false;
      };
    in
    {
      packages.${system} = {
        inherit eden;
      };
      devShells.${system} = {
        inherit eden;
      };
    };
}
