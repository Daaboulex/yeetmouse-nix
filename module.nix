{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.yeetmouse;

  degToRad = x: x * 0.017453292;
  floatRange = lower: upper: lib.types.addCheck lib.types.float (x: x >= lower && x <= upper);

  parameterBasePath = "/sys/module/yeetmouse/parameters";

  yeetmouse = pkgs.yeetmouse.override {
    inherit (config.boot.kernelPackages) kernel;
  };

  # --- Rotation type ---
  rotationType = lib.types.submodule {
    options = {
      angle = lib.mkOption {
        type = floatRange (-180.0) 180.0;
        default = 0.0;
        apply = degToRad;
        description = "Rotation adjustment to apply to mouse inputs (in degrees)";
      };

      snappingAngle = lib.mkOption {
        type = floatRange 0.0 179.9;
        default = 0.0;
        apply = degToRad;
        description = "Rotation angle to snap to";
      };

      snappingThreshold = lib.mkOption {
        type = floatRange 0.0 179.9;
        default = 0.0;
        apply = degToRad;
        description = "Threshold until applying snapping angle";
      };
    };
  };

  # --- Acceleration modes ---
  modesType = lib.types.attrTag {
    linear = lib.mkOption {
      description = ''
        Simplest acceleration mode. Accelerates at a constant rate by multiplying acceleration.
        See [RawAccel: Linear](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#linear)
      '';
      type = lib.types.submodule {
        options = {
          acceleration = lib.mkOption {
            type = floatRange 0.0005 1.0;
            default = 0.15;
            description = "Linear acceleration multiplier";
          };
          useSmoothing = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enables the ability to use smooth capping in the Linear curve";
            apply = x: if x then "1" else "0";
          };
          smoothCap = lib.mkOption {
            type = floatRange 0.1 10.0;
            default = 6.0;
            apply = toString;
            description = "Only used when useSmoothing is enabled, applies a smooth cap to the set value";
          };
        };
      };
      apply = params: [
        {
          value = "1";
          param = "AccelerationMode";
        }
        {
          value = toString params.acceleration;
          param = "Acceleration";
        }
        {
          value = toString params.useSmoothing;
          param = "useSmoothing";
        }
        {
          value = toString params.smoothCap;
          param = "Midpoint";
        }
      ];
    };

    power = lib.mkOption {
      description = ''
        Acceleration mode based on an exponent and multiplier as found in Source Engine games.
        See [RawAccel: Power](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#power)
      '';
      type = lib.types.submodule {
        options = {
          acceleration = lib.mkOption {
            type = floatRange 0.0005 5.0;
            default = 0.15;
            description = "Power acceleration pre-multiplier";
          };
          exponent = lib.mkOption {
            type = floatRange 0.0005 1.0;
            default = 0.2;
            description = "Power acceleration exponent";
          };
          outputOffset = lib.mkOption {
            type = floatRange 0.0 5.0;
            default = 1.0;
            description = "Speed output offset";
          };
          useSmoothing = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enables the ability to use smooth capping in the Power curve";
            apply = x: if x then "1" else "0";
          };
          smoothCap = lib.mkOption {
            type = floatRange 0.1 10.0;
            default = 6;
            apply = toString;
            description = "Only used when useSmoothing is enabled, applies a smooth cap to the set value";
          };
        };
      };
      apply = params: [
        {
          value = "2";
          param = "AccelerationMode";
        }
        {
          value = toString params.acceleration;
          param = "Acceleration";
        }
        {
          value = toString params.exponent;
          param = "Exponent";
        }
        {
          value = toString params.outputOffset;
          param = "Midpoint";
        }
        {
          value = toString params.useSmoothing;
          param = "useSmoothing";
        }
        {
          value = toString params.smoothCap;
          param = "Motivity";
        }
      ];
    };

    classic = lib.mkOption {
      description = ''
        Acceleration mode based on an exponent and multiplier as found in Quake 3.
        See [RawAccel: Classic](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#classic)
      '';
      type = lib.types.submodule {
        options = {
          acceleration = lib.mkOption {
            type = floatRange 0.0005 5.0;
            default = 0.15;
            apply = toString;
            description = "Classic acceleration pre-multiplier";
          };
          exponent = lib.mkOption {
            type = floatRange 2.0 5.0;
            default = 2.0;
            apply = toString;
            description = "Classic acceleration exponent";
          };
          useSmoothing = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enables the ability to use smooth capping in the Classic curve";
            apply = x: if x then "1" else "0";
          };
          smoothCap = lib.mkOption {
            type = floatRange 0.1 10.0;
            default = 6.0;
            apply = toString;
            description = "Only used when useSmoothing is enabled, applies a smooth cap to the set value";
          };
        };
      };
      apply = params: [
        {
          value = "3";
          param = "AccelerationMode";
        }
        {
          value = toString params.acceleration;
          param = "Acceleration";
        }
        {
          value = toString params.exponent;
          param = "Exponent";
        }
        {
          value = toString params.useSmoothing;
          param = "useSmoothing";
        }
        {
          value = toString params.smoothCap;
          param = "Midpoint";
        }
      ];
    };

    motivity = lib.mkOption {
      description = ''
        Acceleration mode based on a sigmoid function with a set mid-point.
        See [RawAccel: Motivity](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#motivity)
      '';
      type = lib.types.submodule {
        options = {
          acceleration = lib.mkOption {
            type = floatRange 0.01 10.0;
            default = 0.15;
            apply = toString;
            description = "Motivity acceleration dividend";
          };
          start = lib.mkOption {
            type = floatRange 0.1 50.0;
            default = 10.0;
            apply = toString;
            description = "Motivity acceleration mid-point";
          };
        };
      };
      apply = params: [
        {
          value = "4";
          param = "AccelerationMode";
        }
        {
          value = toString params.acceleration;
          param = "Acceleration";
        }
        {
          value = toString params.start;
          param = "Midpoint";
        }
      ];
    };

    synchronous = lib.mkOption {
      description = ''
        This acceleration type is designed to match how we naturally perceive changes in speed, using a logarithmic sensitivity curve centered around a "synchronous speed." If the synchronous speed is set correctly, the sensitivity change will align with our intuitive estimation of speed differences.
        See [RawAccel: Synchronous](https://github.com/RawAccelOfficial/rawaccel/blob/master/doc/Guide.md#synchronous)
      '';
      type = lib.types.submodule {
        options = {
          gamma = lib.mkOption {
            type = floatRange 0.01 20.0;
            default = 0.3;
            apply = toString;
            description = "Expresses how fast the change occurs";
          };
          smoothness = lib.mkOption {
            type = floatRange 0.1 20.0;
            default = 1.0;
            apply = toString;
            description = "Affects how fast the changes tails in and out";
          };
          motivity = lib.mkOption {
            type = floatRange 1 10.0;
            default = 2.0;
            apply = toString;
            description = "Expresses how much change will occur";
          };
          syncspeed = lib.mkOption {
            type = floatRange 0.01 20.0;
            default = 2.0;
            apply = toString;
            description = "Works a bit like offset";
          };
          useSmoothing = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable gain";
            apply = x: if x then "1" else "0";
          };
        };
      };
      apply = params: [
        {
          value = "5";
          param = "AccelerationMode";
        }
        {
          value = toString params.gamma;
          param = "Exponent";
        }
        {
          value = toString params.smoothness;
          param = "Midpoint";
        }
        {
          value = toString params.motivity;
          param = "Motivity";
        }
        {
          value = toString params.syncspeed;
          param = "Acceleration";
        }
        {
          value = params.useSmoothing;
          param = "UseSmoothing";
        }
      ];
    };

    natural = lib.mkOption {
      description = ''
        Acceleration mode Natural features a concave curve which starts at 1 and approaches some maximum sensitivity. The sensitivity version of this curve can be found in the game Diabotical.
        See [RawAccel: Natural](https://github.com/RawAccelOfficial/rawaccel/blob/d179e22/doc/Guide.md#natural)
      '';
      type = lib.types.submodule {
        options = {
          acceleration = lib.mkOption {
            type = floatRange 0.001 5.0;
            default = 0.15;
            description = "Natural decay rate";
          };
          midpoint = lib.mkOption {
            type = floatRange 0 50.0;
            default = 0;
            description = "Natural acceleration mid-point";
          };
          exponent = lib.mkOption {
            type = floatRange 0.001 8.0;
            default = 2;
            description = "Natural acceleration limit (smoothness of the applied output curve)";
          };
          useSmoothing = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Natural curve smoothing (Makes the curve smoother)";
            apply = x: if x then "1" else "0";
          };
        };
      };
      apply = params: [
        {
          value = "6";
          param = "AccelerationMode";
        }
        {
          value = toString params.acceleration;
          param = "Acceleration";
        }
        {
          value = toString params.midpoint;
          param = "Midpoint";
        }
        {
          value = toString params.exponent;
          param = "Exponent";
        }
        {
          value = params.useSmoothing;
          param = "UseSmoothing";
        }
      ];
    };

    jump = lib.mkOption {
      description = ''
        Acceleration mode applying gain above a mid-point.
        Optionally, the transition mid-point can be smoothened and a smoothness may be applied to the whole sigmoid function.
        See [RawAccel: Jump](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#jump)
      '';
      type = lib.types.submodule {
        options = {
          acceleration = lib.mkOption {
            type = floatRange 0.01 10.0;
            default = 0.15;
            description = "Jump acceleration dividend";
          };
          midpoint = lib.mkOption {
            type = floatRange 0.1 50.0;
            default = 0.15;
            description = "Jump acceleration mid-point";
          };
          exponent = lib.mkOption {
            type = floatRange 0.0 1.0;
            default = 0.2;
            description = "Jump curve smoothness (smoothness of the applied output curve)";
          };
          useSmoothing = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable Jump smoothing (whether the transition mid-point is smoothed out into the gain curve";
            apply = x: if x then "1" else "0";
          };
        };
      };
      apply = params: [
        {
          value = "7";
          param = "AccelerationMode";
        }
        {
          value = toString params.acceleration;
          param = "Acceleration";
        }
        {
          value = toString params.midpoint;
          param = "Midpoint";
        }
        {
          value = toString params.exponent;
          param = "Exponent";
        }
        {
          value = params.useSmoothing;
          param = "UseSmoothing";
        }
      ];
    };

    lut =
      let
        tuple =
          ts:
          lib.mkOptionType {
            name = "tuple";
            merge = lib.mergeOneOption;
            check = xs: lib.all lib.id (lib.zipListsWith (t: x: t.check x) ts xs);
            description = "tuple of" + lib.concatMapStrings (t: " (${t.description})") ts;
          };
        lutVec = tuple [
          ((floatRange 0.0 100.0) // { description = "Input speed (x)"; })
          ((floatRange 0.0 100.0) // { description = "Output speed ratio (y)"; })
        ];
      in
      lib.mkOption {
        description = ''
          Acceleration mode following a custom curve.
          The curve is specified using individual `[x, y]` points.
          See [RawAccel: Lookup Table](https://github.com/RawAccelOfficial/rawaccel/blob/5b39bb6/doc/Guide.md#look-up-table)
          The acceleration mode for custom curves is represented as a LUT as well. Use the Yeetmouse GUI to convert bezier curves to a LUT.
        '';
        type = lib.types.submodule {
          options = {
            data = lib.mkOption {
              type = lib.types.listOf lutVec;
              default = [ ];
              apply = ls: map (t: "${toString t [ 0 ]},${toString t [ 1 ]}") ls;
              description = "Lookup Table data (a list of `[x, y]` points)";
            };
          };
        };
        apply = params: [
          {
            value = "8";
            param = "AccelerationMode";
          }
          {
            value = lib.concatStringsSep ";" params.data;
            param = "LutDataBuf";
          }
          {
            value = lib.length params.data;
            param = "LutSize";
          }
        ];
      };
  };
in
{
  _class = "nixos";

  options.hardware.yeetmouse = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable yeetmouse kernel module to add configurable mouse acceleration";
    };

    sensitivity =
      let
        sensitivityValue = floatRange 0.01 10.0;
        anisotropyValue = lib.types.submodule {
          description = "Anisotropic sensitivity, separating X and Y movement";
          options = {
            x = lib.mkOption {
              type = sensitivityValue;
              description = "Horizontal sensitivity";
            };
            y = lib.mkOption {
              type = sensitivityValue;
              description = "Vertical sensitivity";
            };
          };
        };
      in
      lib.mkOption {
        type = lib.types.either sensitivityValue anisotropyValue;
        default = 1.0;
        description = "Mouse base sensitivity";
        apply = sens: [
          {
            value = if lib.isAttrs sens then toString sens.x else toString sens;
            param = "Sensitivity";
          }
          {
            value = toString (if lib.isAttrs sens then sens.y / sens.x else 1.0);
            param = "RatioYX";
          }
        ];
      };

    inputCap = lib.mkOption {
      type = lib.types.nullOr (floatRange 0.0 200.0);
      default = null;
      description = "Limit the maximum pointer speed before applying acceleration";
      apply = x: {
        value = if x != null then toString x else "0";
        param = "InputCap";
      };
    };

    outputCap = lib.mkOption {
      type = lib.types.nullOr (floatRange 0.0 100.0);
      default = null;
      description = "Cap maximum sensitivity.";
      apply = x: {
        value = if x != null then toString x else "0";
        param = "OutputCap";
      };
    };

    offset = lib.mkOption {
      type = lib.types.nullOr (floatRange (-50.0) 50.0);
      default = 0.0;
      description = "Acceleration curve offset";
      apply = x: {
        value = toString x;
        param = "Offset";
      };
    };

    preScale = lib.mkOption {
      type = floatRange 0.01 10.0;
      default = 1.0;
      description = "Parameter to adjust for DPI";
      apply = x: {
        value = toString x;
        param = "PreScale";
      };
    };

    rotation = lib.mkOption {
      type = rotationType;
      default = { };
      description = "Adjust mouse rotation input and optionally apply a snapping angle";
      apply = x: [
        {
          value = toString x.angle;
          param = "RotationAngle";
        }
        {
          value = toString x.snappingAngle;
          param = "AngleSnap_Angle";
        }
        {
          value = toString x.snappingThreshold;
          param = "AngleSnap_Threshold";
        }
      ];
    };

    mode = lib.mkOption {
      type = modesType;
      default = {
        linear = { };
      };
      description = "Acceleration mode to apply and their parameters";
      apply =
        params:
        (lib.optionals (params ? linear) params.linear)
        ++ (lib.optionals (params ? power) params.power)
        ++ (lib.optionals (params ? classic) params.classic)
        ++ (lib.optionals (params ? motivity) params.motivity)
        ++ (lib.optionals (params ? synchronous) params.synchronous)
        ++ (lib.optionals (params ? natural) params.natural)
        ++ (lib.optionals (params ? jump) params.jump)
        ++ (lib.optionals (params ? lut) params.lut);
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ yeetmouse ];

    services.udev.extraRules =
      let
        echo = "${pkgs.coreutils}/bin/echo";
        yeetmouseConfig =
          let
            globalParams = [
              cfg.inputCap
              cfg.outputCap
              cfg.offset
              cfg.preScale
            ];
            params = globalParams ++ cfg.sensitivity ++ cfg.rotation ++ cfg.mode;
            paramToString = entry: ''
              ${echo} "${entry.value}" > "${parameterBasePath}/${entry.param}"
            '';
          in
          pkgs.writeShellScriptBin "yeetmouseConfig" ''
            ${lib.concatMapStrings (s: (paramToString s) + "\n") params}
            ${echo} "1" > /sys/module/yeetmouse/parameters/update
          '';
      in
      ''
        SUBSYSTEM=="module", KERNEL=="yeetmouse", ACTION=="add", RUN+="${pkgs.runtimeShell} -c 'chmod 0664 /sys/module/yeetmouse/parameters/* && chgrp users /sys/module/yeetmouse/parameters/*'"
        SUBSYSTEMS=="usb|input|hid", ATTRS{bInterfaceClass}=="03", ATTRS{bInterfaceSubClass}=="01", ATTRS{bInterfaceProtocol}=="02", ATTRS{bInterfaceNumber}=="00", RUN+="${yeetmouseConfig}/bin/yeetmouseConfig"
      '';

    # Fallback: apply yeetmouse config after boot via systemd.
    # The HID udev rule can race with module init (sysfs params
    # don't exist yet when the rule fires), leaving settings at kernel defaults.
    # This service guarantees settings are applied once the module is loaded.
    systemd.services.yeetmouse-config =
      let
        echo = "${pkgs.coreutils}/bin/echo";
        globalParams = [
          cfg.inputCap
          cfg.outputCap
          cfg.offset
          cfg.preScale
        ];
        params = globalParams ++ cfg.sensitivity ++ cfg.rotation ++ cfg.mode;
        paramToString = entry: ''
          ${echo} "${toString entry.value}" > "${parameterBasePath}/${entry.param}"
        '';
      in
      {
        description = "Apply YeetMouse acceleration parameters";
        after = [ "systemd-modules-load.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          # Wait for sysfs to be ready
          for i in $(seq 1 20); do
            [ -f ${parameterBasePath}/update ] && break
            ${pkgs.coreutils}/bin/sleep 0.25
          done
          ${lib.concatMapStrings (s: (paramToString s) + "\n") params}
          ${echo} "1" > ${parameterBasePath}/update
        '';
      };
  };
}
