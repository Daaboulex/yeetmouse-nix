{
  description = "YeetMouse — kernel mouse acceleration driver with 8 accel modes and GUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yeetmouse-src = {
      url = "github:AndyFilter/YeetMouse";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
      yeetmouse-src,
    }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { localSystem.system = system; };
        in
        {
          yeetmouse = pkgs.callPackage ./package.nix {
            inherit (pkgs.linuxPackages) kernel;
            inherit yeetmouse-src;
          };
          default = self.packages.${system}.yeetmouse;
        }
      );

      overlays.default = final: _prev: {
        yeetmouse = final.callPackage ./package.nix {
          inherit (final.linuxPackages) kernel;
          inherit yeetmouse-src;
        };
      };

      nixosModules.default = import ./module.nix;
      homeManagerModules.default = import ./hm-module.nix;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (system: {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = self;
          hooks.nixfmt-rfc-style.enable = true;
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            packages = with pkgs; [ nil ];
          };
        }
      );
    };
}
