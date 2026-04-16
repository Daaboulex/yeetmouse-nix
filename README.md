# yeetmouse-nix

[![CI](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Daaboulex/yeetmouse-nix)](./LICENSE)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![Last commit](https://img.shields.io/github/last-commit/Daaboulex/yeetmouse-nix)](https://github.com/Daaboulex/yeetmouse-nix/commits)
[![Stars](https://img.shields.io/github/stars/Daaboulex/yeetmouse-nix?style=flat)](https://github.com/Daaboulex/yeetmouse-nix/stargazers)
[![Issues](https://img.shields.io/github/issues/Daaboulex/yeetmouse-nix)](https://github.com/Daaboulex/yeetmouse-nix/issues)

YeetMouse kernel mouse acceleration driver packaged for NixOS.

## Features

- Kernel module for hardware-level mouse acceleration (runs in kernel space, zero userspace latency)
- GUI for real-time curve adjustment
- 8 acceleration modes: linear, power, classic, motivity, synchronous, natural, jump, LUT
- Dual compiler detection (GCC and LLVM/Clang for CachyOS LTO kernels)
- G502 libinput HWDB integration (flat profile to prevent double acceleration)
- Udev + systemd service for immediate parameter application on mouse connect

## Usage

Add as a flake input:

```nix
yeetmouse = {
  url = "github:Daaboulex/yeetmouse-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import the NixOS module and overlay:

```nix
imports = [ inputs.yeetmouse.nixosModules.default ];
nixpkgs.overlays = [ inputs.yeetmouse.overlays.default ];
```

Enable in your host config:

```nix
myModules.input.yeetmouse = {
  enable = true;
  devices.g502.enable = true;
};

hardware.yeetmouse = {
  sensitivity = 0.5;
  mode.jump = {
    acceleration = 2.0;
    midpoint = 7.8;
  };
};
```

For the GUI, add the Home Manager module:

```nix
home-manager.sharedModules = [ inputs.yeetmouse.homeManagerModules.default ];
```

## Upstream

[AndyFilter/YeetMouse](https://github.com/AndyFilter/YeetMouse) — auto-updated daily via GitHub Actions.

## License

GPL-2.0 (kernel module)
