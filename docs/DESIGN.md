# Design

Why the packaging is built the way it is. The [README](../README.md) says how to use it.

## A pin and nothing else

This flake is the pin for the fork's `daaboulex` branch. The package and the
NixOS module are the fork's own `nix/package.nix` and `nix/module.nix`. This
flake fetches them at the pinned commit and adds nothing of its own, so the fork
stays the one place they change.

The fork is the flake input `yeetmouse-src`, taken as plain source. `flake.nix`
calls the fork's `nix/package.nix` with the kernel of `pkgs.linuxPackages` and
the pinned commit's short revision, which becomes the package version. It
imports the fork's `nix/module.nix` with the same short revision.

The package is built for the kernel it is given. The flake's own package and
the overlay's `pkgs.yeetmouse` are given `linuxPackages`. The module gives its
copy the kernel the system boots.

## Both architectures

The flake declares `x86_64-linux` and `aarch64-linux`. The fork's fixed point is
portable C.

## What the module does on a machine

The module seeds the default config, the profiles and `devices.conf` from files
or a Raw Accel export, and loads them at boot.

It builds its own copy of the package against `config.boot.kernelPackages`, so
the driver matches the kernel the system boots. It adds that package to `boot.extraModulePackages` and to
`environment.systemPackages`, and names `yeetmouse` in `boot.kernelModules`.

It creates the group `yeetmouse`. A udev rule gives that group the driver's
device with mode 0660 and starts `yeetmouse.service` when the device appears.

The service runs three steps:

1. It creates `/etc/yeetmouse` and `/etc/yeetmouse/profiles` for the group, runs
   `yeetmousectl setup /etc --seed` with the files built for this system, and
   hands the driver's parameters under `/sys/module/yeetmouse/parameters` to
   the group.
2. It runs `yeetmousectl touchpads --record`. A failure here does not fail the
   service.
3. It runs `yeetmousectl load`.

Seeding copies a file only when it is missing, so the GUI owns it afterwards.
The default config is seeded as `/etc/yeetmouse/default.conf`, which
`/etc/yeetmouse.conf` links to.

The default config comes from the first of these that is set: `defaultConfig`,
then the first profile of `rawAccel`, then the curve options (`sensitivity`,
`inputCap`, `outputCap`, `offset`, `preScale`, `rotation`, `mode`).

## What the build refuses

`rawAccel` is converted at build time by `yeetmousectl import-rawaccel`. A
setting YeetMouse cannot reproduce exactly fails the build.

A profile named both in `profiles` and in the Raw Accel file fails the build
with "the profile NAME is given twice". The assembled files then go through
`yeetmousectl check`.

A profile name uses letters, digits, `.`, `_` or `-`, starts with a letter or
digit, has at most 31 characters and is not `disabled`. An assertion refuses
any other name.

## Why two projects are watched

Official YeetMouse is watched so that its new commits get merged into the
fork's `daaboulex` branch.

KWin is watched for the day it can hand a custom acceleration curve to libinput
(kwin!6937), the switch the fork's touchpad curves wait for. When that day
comes the workflow says to check the final property names against the fork's
`gui/Profiles.cpp` and enable the touchpad curve.

How both watches run is in [DEVELOPMENT.md](DEVELOPMENT.md).
