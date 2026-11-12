# YeetMouse for NixOS

YeetMouse is a kernel module that adds configurable mouse acceleration. This
flake packages the
[Daaboulex fork](https://github.com/Daaboulex/YeetMouse/tree/daaboulex) of
[AndyFilter/YeetMouse](https://github.com/AndyFilter/YeetMouse) for NixOS, with
Raw Accel parity, profiles, per-device curves and a GUI. It suits someone who
wants an acceleration curve on NixOS, drawn in the GUI or carried over from
Raw Accel.

It builds for `x86_64-linux` and `aarch64-linux`. The checks build the package
and the settings of a NixOS configuration seeded from a Raw Accel file. None of
them loads the driver or moves a pointer, so how it behaves on a real mouse is
not tested here.

## What you get

- `nixosModules.default` adds the `hardware.yeetmouse` options. It builds the
  driver for the kernel your system boots, loads it and installs the programs.
- `packages.yeetmouse`, also the default package, holds the kernel module,
  `yeetmousectl` and the `yeetmouse` GUI.
- `overlays.default` adds `pkgs.yeetmouse`, built against `linuxPackages`.

## Install

Add the flake:

```nix
{
  inputs.yeetmouse = {
    url = "github:Daaboulex/yeetmouse-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then import the module and switch it on:

```nix
{ inputs, ... }:
{
  imports = [ inputs.yeetmouse.nixosModules.default ];
  hardware.yeetmouse.enable = true;
}
```

With nothing else set, the driver runs the module's default, a linear curve at
sensitivity 1.

The module creates a `yeetmouse` group that owns the driver's device and
`/etc/yeetmouse`. Put your user in it to change settings without root.

## Use

`yeetmouse` opens the GUI. `yeetmousectl` is the command-line tool.

```bash
yeetmousectl run <profile> -- <command>
```

That starts a program on one profile, which is how a game gets its own.

To start from settings you already have, hand the module files. These options
sit under `hardware.yeetmouse`.

| Option | What it is for |
|---|---|
| `rawAccel` | A Raw Accel 1.7 `settings.json`, converted when the system is built |
| `defaultConfig` | A config file in `yeetmousectl`'s format, for every mouse `devices.conf` does not list |
| `profiles` | Named profiles, one file each |
| `devices` | A `devices.conf`, one line per mouse |
| `mode`, `sensitivity` | The curve and the base sensitivity written as Nix options, used when no file gives the default config |

From a Raw Accel export:

```nix
{
  hardware.yeetmouse = {
    enable = true;
    rawAccel = ./settings.json;
  };
}
```

Each file is copied into `/etc/yeetmouse` only where none exists yet, and
applied each time the driver loads. After that the GUI owns the files.

Every option, with its type and default: [docs/OPTIONS.md](docs/OPTIONS.md).

The fork's
[README](https://github.com/Daaboulex/YeetMouse/tree/daaboulex) and the option
descriptions in its `nix/module.nix` are the reference for the driver, the
profiles, per-device curves, Raw Accel import and export, and `yeetmousectl run`
for per-game profiles.

## Known limits

- A file already in `/etc/yeetmouse` is never replaced. Changing an option
  later does not change a machine that was already seeded.
- `rawAccel` fails the build when the file holds a setting YeetMouse cannot
  reproduce exactly.
- Only the module builds the driver for the kernel you boot. The overlay and
  the flake's own package build against `linuxPackages`.
- The fork's touchpad curves wait for KWin to be able to hand a custom
  acceleration curve to libinput.

## When something does not work

The build runs `yeetmousectl check` over the files you give it. A file it
rejects fails the build.

On a running machine the settings are applied by one service:

```bash
systemctl status yeetmouse.service
```

The fork's
[NixOS notes](https://github.com/Daaboulex/YeetMouse/blob/daaboulex/nix/README.md)
say how to make a changed option take effect and how to load a new driver
without a reboot.

## More

- [docs/DESIGN.md](docs/DESIGN.md): why this flake is only a pin, what the
  module does on a machine, why KWin is watched
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md): building, the checks, how the pin
  moves, what is tracked upstream
- [SECURITY.md](SECURITY.md): how to report a vulnerability

## License

This packaging flake is [GPL-2.0](./LICENSE) licensed, matching YeetMouse, whose kernel module
licence propagates. The `yeetmouse` package declares no `meta.license`.
