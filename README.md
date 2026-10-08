# yeetmouse-nix

<!-- BEGIN generated:badges -->
[![CI](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml)
[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](./LICENSE)
<!-- END generated:badges -->

YeetMouse for NixOS, built from the Daaboulex fork.

<!-- BEGIN generated:upstream -->
## Upstream

| | |
|---|---|
| **Project** | [Daaboulex/YeetMouse](https://github.com/Daaboulex/YeetMouse/tree/daaboulex), a fork of [AndyFilter/YeetMouse](https://github.com/AndyFilter/YeetMouse) |
| **License** | GPL-2.0 |
| **Tracked** | Git commits (daaboulex) |

<!-- END generated:upstream -->

## What Is This?

The pin for the fork's `daaboulex` branch. The package and the NixOS module are the fork's own
`nix/package.nix` and `nix/module.nix`; this flake fetches them at the pinned commit and adds
nothing of its own, so the fork stays the one place they change.

- **Follows the fork** - `update.yml` moves the pin to the newest `daaboulex` commit daily and
  builds it before pushing.
- **Watches official YeetMouse** - `watch.yml` fails daily while `AndyFilter/YeetMouse` master
  has commits the fork lacks, listing them, so they get merged into `daaboulex`.
- **Watches KWin** - the same workflow fails once KWin can hand a custom acceleration curve to
  libinput (kwin!6937), the switch the fork's touchpad curves wait for.
- **Both architectures** - x86_64-linux and aarch64-linux; the fork's fixed point is portable C.

## Components

| Component | Type | Description |
|---|---|---|
| `yeetmouse` (default) | package | Kernel module, `yeetmousectl` and the `yeetmouse` GUI, built for the kernel it is given |
| `nixosModules.default` | NixOS module | `hardware.yeetmouse`: seeds `/etc/yeetmouse.conf`, profiles and `devices.conf` from files or a Raw Accel export, loads them at boot; the GUI owns them afterwards |
| `overlays.default` | overlay | `pkgs.yeetmouse` against `linuxPackages` |

The fork's README and `nix/module.nix` option descriptions are the reference for the driver,
the profiles, per-device curves, Raw Accel import and export, and `yeetmousectl run` for
per-game profiles.

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

Then import the module and enable it:

```nix
{ inputs, ... }:
{
  imports = [ inputs.yeetmouse.nixosModules.default ];
  hardware.yeetmouse = {
    enable = true;
    rawAccel = ./settings.json;
  };
}
```

<!-- END generated:installation -->

## Development

```bash
nix develop
nix fmt
nix flake check --no-eval-cache
nix build
```

`nix flake check` builds the package for the runner's system and a NixOS configuration that
seeds the fork's Raw Accel fixture, so a converter or module regression fails it.

## License

This packaging flake is [GPL-2.0](./LICENSE) licensed, matching YeetMouse, whose kernel module
licence propagates.

<!-- BEGIN generated:footer -->
<!-- END generated:footer -->
