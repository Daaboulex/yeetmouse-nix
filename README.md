# yeetmouse-nix

<!-- BEGIN generated:badges -->
[![CI](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml)
[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](./LICENSE)
<!-- END generated:badges -->

YeetMouse kernel mouse acceleration driver packaged for NixOS.

<!-- BEGIN generated:upstream -->
## Upstream

| | |
|---|---|
| **Project** | [AndyFilter/YeetMouse](https://github.com/AndyFilter/YeetMouse) |
| **License** | GPL-2.0 |
| **Tracked** | Git commits (master) |

<!-- END generated:upstream -->

## What Is This?

A Nix flake that builds the YeetMouse kernel module + GUI from upstream master:

- **Daily upstream tracking** at 06:00 UTC — new commits on `master` land here within a day
- **Pre-build verification** — fail-closed pipeline (eval → build → ELF check) before any push to `main`
- **Dual-compiler kernel detection** — auto-selects GCC vs LLVM/Clang to match CachyOS LTO and stock kernels
- **Two integration paths** — NixOS module (`hardware.yeetmouse`) for module + udev + sensitivity; HM module (`programs.yeetmouse`) for the GUI

## Components

| Component | Type | Description |
|---|---|---|
| `yeetmouse` (default) | package | Kernel module + `bin/yeetmouse` GUI; 8 modes (linear, power, classic, motivity, synchronous, natural, jump, LUT) |
| `nixosModules.default` | NixOS module | `hardware.yeetmouse.*` (sensitivity + mode params) + udev + systemd service for immediate parameter apply on mouse connect |
| `homeModules.default` | HM module | `programs.yeetmouse` — installs the GUI for the user |

## Features

- Kernel module for hardware-level mouse acceleration (runs in kernel space, zero userspace latency)
- GUI for real-time curve adjustment
- 8 acceleration modes: linear, power, classic, motivity, synchronous, natural, jump, LUT
- Dual compiler detection (GCC and LLVM/Clang for CachyOS LTO kernels)
- Udev + systemd service for immediate parameter application on mouse connect

<!-- BEGIN generated:installation -->
## Installation

Add as a flake input:

```nix
{
  inputs.yeetmouse = {
    url = "github:Daaboulex/yeetmouse-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then use the package:

```nix
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [ inputs.yeetmouse.packages.${pkgs.system}.default ];
}
```

<!-- END generated:installation -->

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
hardware.yeetmouse = {
  enable = true;
  sensitivity = 0.5;
  mode.jump = {
    acceleration = 2.0;
    midpoint = 7.8;
  };
};
```

For the GUI, add the Home Manager module:

```nix
home-manager.sharedModules = [ inputs.yeetmouse.homeModules.default ];
```

## Development

```bash
git clone https://github.com/Daaboulex/yeetmouse-nix
cd yeetmouse-nix
nix develop                       # enter dev shell, installs pre-commit hooks
nix fmt                           # format flake + module
nix flake check --no-build        # eval check
nix build                         # build the kernel module + GUI against the active kernel
```

CI runs the same chain daily via `.github/workflows/update.yml`; manual updates rarely needed.

## License

This packaging flake is [GPL-2.0](./LICENSE) licensed (matches upstream — kernel module licenses propagate). Upstream YeetMouse is [GPL-2.0](https://github.com/AndyFilter/YeetMouse/blob/master/LICENSE).

<!-- BEGIN generated:footer -->
<!-- END generated:footer -->
