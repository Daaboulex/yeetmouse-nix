{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  cfg = config.programs.yeetmouse;
  hasDriver = (osConfig.hardware.yeetmouse.enable or false);
in
{
  options.programs.yeetmouse = {
    enable = lib.mkEnableOption "YeetMouse GUI";
  };

  config = lib.mkIf (cfg.enable && hasDriver) {
    home.packages = [ pkgs.yeetmouse ];
  };
}
