{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.custom.gui;
in {
  options.custom.gui = {
    enable = mkEnableOption "Enable xserver";
    autorun = mkOption { type = types.bool; default = true; };
  };

  config = {
    services.xserver = {
      enable = cfg.enable;
      autorun = cfg.autorun;
    };
  };
}
