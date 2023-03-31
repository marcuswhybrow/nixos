{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types mkEnableOption;
  cfg = config.custom.boot;
in {
  options.custom.boot = {
    efi = {
      enable = mkEnableOption "Enable EFI Boot";
      mountPoint = mkOption { type = types.str; };
    };
    grub = {
      enable = mkEnableOption "Enable Grub Boot";
      device = mkOption { type = types.str; };
    };
  };

  config = {
    boot.loader = (if cfg.efi.enable then {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = cfg.efi.mountPoint;
    } else if cfg.grub.enable then {
      grub = {
        enable = true;
        inherit (cfg.grub) device;
        useOSProber = true;
      };
    } else {});
  };
}
