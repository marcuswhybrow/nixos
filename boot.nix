{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types;
  cfg = config.custom.boot;
in {
  options.custom.boot = {
    mountPoint = mkOption { type = types.str; };
  };

  config = {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = cfg.mountPoint;
    };
  };
}
