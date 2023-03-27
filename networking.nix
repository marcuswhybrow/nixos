{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption mkEnableOption types mkDefault;
  cfg = config.custom.networking;
in {
  options.custom.networking = {
    hostName = mkOption { type = types.str; };
  };

  config = {
    networking = {
      useDHCP = mkDefault true;
      hostName = cfg.hostName;
      networkmanager.enable = true;
    };
  };
}
