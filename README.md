# yeetmouse-nix

YeetMouse kernel mouse acceleration driver packaged for NixOS.

[![CI](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml)

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
