{
  description = "YeetMouse — kernel mouse acceleration driver with 8 accel modes and GUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:Daaboulex/nix-packaging-standard?ref=v2.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };
    yeetmouse-src = {
      url = "github:AndyFilter/YeetMouse";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.std.flakeModules.base ];

      flake = {
        nixosModules.default = import ./module.nix;
        homeManagerModules.default = import ./hm-module.nix;

        overlays.default = final: _prev: {
          inherit (inputs.self.packages.${final.stdenv.hostPlatform.system}) yeetmouse;
        };
      };

      perSystem =
        { pkgs, ... }:
        let
          yeetmouse = pkgs.callPackage ./package.nix {
            inherit (pkgs.linuxPackages) kernel;
            inherit (inputs) yeetmouse-src;
          };
        in
        {
          packages = {
            default = yeetmouse;
            inherit yeetmouse;
          };
        };
    };
}
