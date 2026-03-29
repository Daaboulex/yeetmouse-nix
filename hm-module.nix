{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  cfg = config.myModules.home.yeetmouse;
  # Only install the GUI when the NixOS-level driver module is active
  hasDriver = osConfig.hardware.yeetmouse.enable or false;
in
{
  options.myModules.home.yeetmouse.enable =
    lib.mkEnableOption "YeetMouse GUI (requires NixOS yeetmouse driver)";

  config = lib.mkIf (cfg.enable && hasDriver) {
    home.packages = [
      (pkgs.yeetmouse.override {
        inherit (osConfig.boot.kernelPackages) kernel;
      })
    ];
  };
}
