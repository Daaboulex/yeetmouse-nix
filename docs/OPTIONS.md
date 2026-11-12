# Options

Every option the modules of this flake declare. This file is generated from the module sources: change a description there, then run `nix run .#std-write-option-reference`.

## NixOS module

### `hardware.yeetmouse.enable`

Enable yeetmouse kernel module to add configurable mouse acceleration

Type: `boolean`. Default: `false`.

### `hardware.yeetmouse.defaultConfig`

Config file in yeetmousectl's format, seeded as /etc/yeetmouse/default.conf, which
/etc/yeetmouse.conf links to: the settings of every
mouse devices.conf does not list. When null, the options above render it, or rawAccel
provides it. Seeding copies a file only when it is missing, so the GUI owns it afterwards.

Type: `null or absolute path`. Default: `null`.

### `hardware.yeetmouse.devices`

devices.conf seeded as /etc/yeetmouse/devices.conf: one line per mouse,
"vvvv:pppp <profile|disabled> preScale= minTime= maxTime= fixedTime=".

Type: `null or absolute path`. Default: `null`.

### `hardware.yeetmouse.inputCap`

Limit the maximum pointer speed before applying acceleration

Type: `null or floating point number`. Default: `null`.

### `hardware.yeetmouse.mode`

Acceleration mode to apply and their parameters

Type: `attribute-tagged union with choices: classic, jump, linear, lut, motivity, natural, power, synchronous`.

Default:

```nix
{
  linear = { };
}
```

### `hardware.yeetmouse.mode.classic`

Acceleration mode based on an exponent and multiplier as found in Quake 3.
See [RawAccel: Classic](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#classic)

Type: `submodule`.

### `hardware.yeetmouse.mode.classic.acceleration`

Classic acceleration pre-multiplier

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.classic.exponent`

Classic acceleration exponent

Type: `floating point number`. Default: `2.0`.

### `hardware.yeetmouse.mode.classic.smoothCap`

Only used when useSmoothing is enabled, it a applies a smooth cap to the set value

Type: `floating point number`. Default: `6.0`.

### `hardware.yeetmouse.mode.classic.useSmoothing`

Enables the ability to use smooth capping in the Classic curve

Type: `boolean`. Default: `false`.

### `hardware.yeetmouse.mode.jump`

Acceleration mode applying gain above a mid-point.
Optionally, the transition mid-point can be smoothened and a smoothness may be applied to the whole sigmoid function.
See [RawAccel: Jump](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#jump)

Type: `submodule`.

### `hardware.yeetmouse.mode.jump.acceleration`

Jump acceleration dividend

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.jump.midpoint`

Jump acceleration mid-point

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.jump.smoothness`

Jump curve smoothness (smoothness of the applied output curve)

Type: `floating point number`. Default: `0.2`.

### `hardware.yeetmouse.mode.jump.useSmoothing`

Enable Jump smoothing (whether the transition mid-point is smoothed out into the gain curve

Type: `boolean`. Default: `true`.

### `hardware.yeetmouse.mode.linear`

Simplest acceleration mode. Accelerates at a constant rate by multiplying acceleration.
See [RawAccel: Linear](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#linear)

Type: `submodule`.

### `hardware.yeetmouse.mode.linear.acceleration`

Linear acceleration multiplier

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.linear.smoothCap`

Only used when useSmoothing is enabled, it a applies a smooth cap to the set value

Type: `floating point number`. Default: `6.0`.

### `hardware.yeetmouse.mode.linear.useSmoothing`

Enables the ability to use smooth capping in the Linear curve

Type: `boolean`. Default: `false`.

### `hardware.yeetmouse.mode.lut`

Acceleration mode following a custom curve.
The curve is specified using individual `[x, y]` points.
See [RawAccel: Lookup Table](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#look-up-table)
The acceleration mode for custom curves is represented as a LUT as well. Use the Yeetmouse GUI to convert bezier curves to a LUT.

Type: `submodule`.

### `hardware.yeetmouse.mode.lut.data`

Lookup Table data (a list of `[x, y]` points)

Type: `list of (tuple of (Input speed (x)) (Output speed ratio (y)))`. Default: `[ ]`.

### `hardware.yeetmouse.mode.motivity`

Acceleration mode based on a sigmoid function with a set mid-point.
See [RawAccel: Motivity](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#motivity)

Type: `submodule`.

### `hardware.yeetmouse.mode.motivity.acceleration`

Motivity acceleration dividend

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.motivity.midpoint`

Motivity acceleration mid-point

Type: `floating point number`. Default: `10.0`.

### `hardware.yeetmouse.mode.natural`

Acceleration mode Natural features a concave curve which starts at 1 and approaches some maximum sensitivity. The sensitivity version of this curve can be found in the game Diabotical.
See [RawAccel: Natural](https://github.com/RawAccelOfficial/rawaccel/blob/d179e22/doc/Guide.md#natural)

Type: `submodule`.

### `hardware.yeetmouse.mode.natural.acceleration`

Natural decay rate

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.natural.limit`

Natural acceleration limit (smoothness of the applied output curve)

Type: `floating point number`. Default: `2.0`.

### `hardware.yeetmouse.mode.natural.midpoint`

Natural acceleration mid-point

Type: `floating point number`. Default: `0.0`.

### `hardware.yeetmouse.mode.natural.useSmoothing`

Enable Natural curve smoothing (Makes the curve smoother)

Type: `boolean`. Default: `false`.

### `hardware.yeetmouse.mode.power`

Acceleration mode based on an exponent and multiplier as found in Source Engine games.
See [RawAccel: Power](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#power)

Type: `submodule`.

### `hardware.yeetmouse.mode.power.acceleration`

Power acceleration pre-multiplier

Type: `floating point number`. Default: `0.15`.

### `hardware.yeetmouse.mode.power.exponent`

Power acceleration exponent

Type: `floating point number`. Default: `0.2`.

### `hardware.yeetmouse.mode.power.outputOffset`

Speed output offset

Type: `floating point number`. Default: `1.0`.

### `hardware.yeetmouse.mode.power.smoothCap`

Only used when useSmoothing is enabled, it a applies a smooth cap to the set value

Type: `floating point number`. Default: `6.0`.

### `hardware.yeetmouse.mode.power.useSmoothing`

Enables the ability to use smooth capping in the Power curve

Type: `boolean`. Default: `false`.

### `hardware.yeetmouse.mode.synchronous`

This acceleration type is designed to match how we naturally perceive changes in speed, using a logarithmic sensitivity curve centered around a "synchronous speed." If the synchronous speed is set correctly, the sensitivity change will align with our intuitive estimation of speed differences.
See [RawAccel: Synchronous](https://github.com/RawAccelOfficial/rawaccel/blob/master/doc/Guide.md#synchronous)

Type: `submodule`.

### `hardware.yeetmouse.mode.synchronous.gamma`

Expresses how fast the change occurs

Type: `floating point number`. Default: `0.3`.

### `hardware.yeetmouse.mode.synchronous.motivity`

Expresses how much change will occur

Type: `floating point number`. Default: `2.0`.

### `hardware.yeetmouse.mode.synchronous.smoothness`

Affects how fast the changes tails in and out

Type: `floating point number`. Default: `1.0`.

### `hardware.yeetmouse.mode.synchronous.syncspeed`

Works a bit like offset

Type: `floating point number`. Default: `2.0`.

### `hardware.yeetmouse.mode.synchronous.useSmoothing`

Enable gain

Type: `boolean`. Default: `true`.

### `hardware.yeetmouse.offset`

Acceleration curve offset

Type: `null or floating point number`. Default: `0.0`.

### `hardware.yeetmouse.outputCap`

Cap maximum sensitivity.

Type: `null or floating point number`. Default: `null`.

### `hardware.yeetmouse.preScale`

Parameter to adjust for DPI

Type: `floating point number`. Default: `1.0`.

### `hardware.yeetmouse.profiles`

Named profiles seeded as /etc/yeetmouse/profiles/<name>.conf: curve settings in
yeetmousectl's format, without preScale, minTime, maxTime or fixedTime, which belong to a
mouse's line in devices.conf. Run one for a game with `yeetmousectl run <name> -- %command%`.

Type: `attribute set of absolute path`. Default: `{ }`. Example: `{ power = ./power.conf; }`.

### `hardware.yeetmouse.rawAccel`

Raw Accel 1.7 settings.json converted at build time: its first profile with its default
device settings becomes the default config, and its profiles and devices join the ones above.
A setting YeetMouse cannot reproduce exactly fails the build.

Type: `null or absolute path`. Default: `null`.

### `hardware.yeetmouse.rotation`

Adjust mouse rotation input and optionally apply a snapping angle

Type: `submodule`. Default: `{ }`.

### `hardware.yeetmouse.rotation.angle`

Rotation adjustment to apply to mouse inputs (in degrees)

Type: `floating point number`. Default: `0.0`.

### `hardware.yeetmouse.rotation.snappingAngle`

Rotation angle to snap to

Type: `floating point number`. Default: `0.0`.

### `hardware.yeetmouse.rotation.snappingThreshold`

Threshold until applying snapping angle

Type: `floating point number`. Default: `0.0`.

### `hardware.yeetmouse.sensitivity`

Mouse base sensitivity

Type: `floating point number or (Anisotropic sensitivity, separating X and Y movement)`. Default: `1.0`.
