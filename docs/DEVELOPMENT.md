# Development

```bash
nix develop
nix fmt
nix flake check --no-eval-cache
nix build
```

The dev shell, the formatter and the lint hooks come from
`inputs.std.flakeModules.base`, the
[nix-packaging-standard](https://github.com/Daaboulex/nix-packaging-standard).
The flake's own lock follows nixpkgs `nixos-unstable`.

## Checks

`nix flake check` builds the package for the runner's system and a NixOS
configuration that seeds the fork's Raw Accel fixture, so a converter or module
regression fails it.

- `raw-accel-seed` builds `yeetmouse.service` of a NixOS configuration whose
  `rawAccel` is the fork's `tests/fixtures/rawaccel/power-velocity-output-cap.json`.
  Building the unit builds the package, converts the fixture and runs
  `yeetmousectl check` on the result.
- `module-eval-nixos` evaluates a NixOS configuration with
  `hardware.yeetmouse.enable = true`.
- The standard adds a build of every package and its own conformance checks.

No check loads the driver.

[`ci.yml`](../.github/workflows/ci.yml) runs the standard's package CI on a push
to `main` or `master`, on a pull request and on demand. Its results are at
<https://github.com/Daaboulex/yeetmouse-nix/actions/workflows/ci.yml>.

## Upstream

| | |
|---|---|
| Project | [Daaboulex/YeetMouse](https://github.com/Daaboulex/YeetMouse/tree/daaboulex), a fork of [AndyFilter/YeetMouse](https://github.com/AndyFilter/YeetMouse) |
| License | GPL-2.0 |
| Tracked | Git commits (daaboulex) |

## How the pin moves

[`update.yml`](../.github/workflows/update.yml) moves the pin to the newest
`daaboulex` commit daily and builds it before pushing. The pinned commit is
recorded in `version.json` and in `flake.lock`. What the updater follows is
declared in `.github/update.json`.

[`maintenance.yml`](../.github/workflows/maintenance.yml) refreshes `flake.lock`
weekly unless the repository variable `MAINTENANCE_CADENCE` says otherwise.

## Watches

[`watch.yml`](../.github/workflows/watch.yml) runs daily and has two jobs.

- It fails while `AndyFilter/YeetMouse` master has commits the fork lacks,
  listing them.
- It fails once KWin can hand a custom acceleration curve to libinput. It reads
  the state of merge request kwin!6937 and looks for
  `pointerAccelerationCustomPoints` in `src/backends/libinput/device.h` at
  KWin's newest tag.

Why these two are watched is in [DESIGN.md](DESIGN.md).
