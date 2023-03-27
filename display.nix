{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.display;
in {
  options.custom.display = {
    adjustableBrightness.enable = mkEnableOption "Enable adjustable screen brightness";
  };

  config = {
    programs.light.enable = mkIf cfg.adjustableBrightness.enable true;
  };
}
