# yeetmouse-nix

[![CI](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Daaboulex/yeetmouse-nix)](./LICENSE)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![Last commit](https://img.shields.io/github/last-commit/Daaboulex/yeetmouse-nix)](https://github.com/Daaboulex/yeetmouse-nix/commits)
[![Stars](https://img.shields.io/github/stars/Daaboulex/yeetmouse-nix?style=flat)](https://github.com/Daaboulex/yeetmouse-nix/stargazers)
[![Issues](https://img.shields.io/github/issues/Daaboulex/yeetmouse-nix)](https://github.com/Daaboulex/yeetmouse-nix/issues)

YeetMouse kernel mouse acceleration driver packaged for NixOS.

## Upstream

This is a **Nix packaging wrapper** — not the original project. All credit for YeetMouse goes to:

- **Author**: [AndyFilter](https://github.com/AndyFilter)
- **Repository**: [github.com/AndyFilter/YeetMouse](https://github.com/AndyFilter/YeetMouse)
- **License**: [GPL-2.0](https://github.com/AndyFilter/YeetMouse/blob/master/LICENSE) (kernel module)

Tracks `master` via `github-commit`. Daily upstream check at 06:00 UTC.

## What Is This?

A Nix flake that builds the YeetMouse kernel module + GUI from upstream master with full CI infrastructure:

- **Daily upstream tracking** at 06:00 UTC — new commits on `master` land here within a day
- **Pre-build verification** — fail-closed pipeline (eval → build → ELF check) before any push to `main`
- **Dual-compiler kernel detection** — auto-selects GCC vs LLVM/Clang to match CachyOS LTO and stock kernels
- **Per-device profiles** — `myModules.input.yeetmouse.devices.<dev>.enable` with bundled G502 libinput HWDB rule (flat-profile, prevents double acceleration)
- **Two integration paths** — NixOS module (`hardware.yeetmouse`) for module + udev + sensitivity; HM module (`programs.yeetmouse`) for the GUI

## Components

| Component | Type | Description |
|---|---|---|
| `yeetmouse-driver` | kernel module | Hardware-level mouse acceleration in kernel space (zero userspace latency); 8 modes (linear, power, classic, motivity, synchronous, natural, jump, LUT) |
| `yeetmouse-gui` | package | Real-time curve adjustment GUI |
| `nixosModules.default` | NixOS module | `hardware.yeetmouse.*` (sensitivity + mode params) + `myModules.input.yeetmouse.*` (toggles + per-device profiles like G502) + udev + systemd service for immediate parameter apply on mouse connect |
| `homeManagerModules.default` | HM module | GUI installation for the user |

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

## Development

```bash
git clone https://github.com/Daaboulex/yeetmouse-nix
cd yeetmouse-nix
nix develop                       # enter dev shell, installs pre-commit hooks
nix fmt                           # format flake + module
nix flake check --no-build        # eval check
nix build                         # build the kernel module against the active kernel
nix build .#yeetmouse-gui         # build the GUI
```

CI runs the same chain daily via `.github/workflows/update.yml`; manual updates rarely needed.

## License

This packaging flake is [GPL-2.0](./LICENSE) licensed (matches upstream — kernel module licenses propagate). Upstream YeetMouse is [GPL-2.0](https://github.com/AndyFilter/YeetMouse/blob/master/LICENSE).
