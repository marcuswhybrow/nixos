{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption mkEnableOption types mkDefault;
  cfg = config.custom.networking;
in {
  options.custom.networking = {
    hostName = mkOption { type = types.str; };
    firewall = {
      enable = mkOption { type = types.bool; default = true; };
      open.tcp = mkOption { type = with types; listOf int; default = []; };
      open.udp = mkOption { type = with types; listOf int; default = []; };
    };
  };

  config = {
    networking = {
      useDHCP = mkDefault true;
      hostName = cfg.hostName;
      networkmanager.enable = mkDefault true;
      firewall = {
        enable = mkDefault cfg.firewall.enable;
        allowedTCPPorts = cfg.firewall.open.tcp;
        allowedUDPPorts = cfg.firewall.open.udp;
      };
    };
  };
}
