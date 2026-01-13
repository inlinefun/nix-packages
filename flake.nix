{
  description = "inlinefun's nix packages flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      overlays.default = final: prev: {
        eden = import ./packages/eden/package.nix {
          pkgs = prev;
          cacheBuilds = final.config.eden.cacheBuilds or false;
        };
        ninjabrain-bot = import ./packages/ninjabrain-bot/package.nix {
          pkgs = prev;
        };
        waywall = import ./packages/waywall/package.nix {
          pkgs = prev;
        };
      };
      packages.${system} =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          eden = pkgs.eden;
          waywall = pkgs.waywall;
          ninjabrain-bot = pkgs.ninjabrain-bot;
        };
    };
}
