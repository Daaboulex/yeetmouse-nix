{
  description = "YeetMouse from the Daaboulex fork: kernel mouse acceleration with Raw Accel parity, profiles, per-device curves and a GUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:Daaboulex/nix-packaging-standard?ref=v2.40.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };
    yeetmouse-src = {
      url = "github:Daaboulex/YeetMouse/daaboulex";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      src = inputs.yeetmouse-src;
      yeetmouseFor =
        pkgs:
        pkgs.callPackage "${src}/nix/package.nix" {
          inherit (pkgs.linuxPackages) kernel;
          inherit (src) shortRev;
        };
      module = import "${src}/nix/module.nix" src.shortRev;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [ inputs.std.flakeModules.base ];

      flake = {
        nixosModules.default = module;
        overlays.default = final: _prev: { yeetmouse = yeetmouseFor final; };
      };

      perSystem =
        { pkgs, system, ... }:
        let
          seeded = inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              module
              {
                boot.isContainer = true;
                system.stateVersion = inputs.nixpkgs.lib.trivial.release;
                hardware.yeetmouse = {
                  enable = true;
                  rawAccel = "${src}/tests/fixtures/rawaccel/power-velocity-output-cap.json";
                };
              }
            ];
          };
        in
        {
          packages = {
            default = yeetmouseFor pkgs;
            yeetmouse = yeetmouseFor pkgs;
          };
          checks = {
            module-eval-nixos = inputs.std.lib.nixosModuleCheck {
              inherit (inputs) nixpkgs;
              inherit system module;
              config.hardware.yeetmouse.enable = true;
            };
            raw-accel-seed = seeded.config.systemd.units."yeetmouse.service".unit;
          };
        };
    };
}
