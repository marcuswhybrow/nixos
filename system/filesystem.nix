{ config, lib, plgs, ... }: let
  inherit (lib) mkOption types mkIf;
  cfg = config.custom.filesystem;
  keyFile = "/crypto_keyfile.bin";
  doSwap = cfg.swap.device != null;
  doSwapEncryption = doSwap && cfg.swap.isEncrypted;
  doEncryption = cfg.root.isEncrypted || cfg.swap.isEncrypted;
in {
  options.custom.filesystem = {
    boot = {
      device = mkOption { type = types.str; };
      fsType = mkOption { type = types.str; };
      mountPoint = mkOption { type = with types; nullOr str; default = null; };
    };
    root = {
      device = mkOption { type = types.str; };
      fsType = mkOption { type = types.str; };
      isEncrypted = mkOption { type = types.bool; default = false; };
    };
    swap = {
      # Assume max 1 swap partion
      device = mkOption { type = types.str; default = null; };
      isEncrypted = mkOption { type = types.bool; default = false; };
    };
  };

  config = {
    # Sort out encryption
    boot.initrd = {
      secrets = mkIf doSwapEncryption { "${keyFile}" = null; };
      luks.devices.root.device = mkIf cfg.root.isEncrypted cfg.root.device;
      luks.devices.swap = mkIf doSwapEncryption {
        device = cfg.swap.device;
        keyFile = keyFile;
      };

      # https://nixos.wiki/wiki/Full_Disk_Encryption#Perf_test
      availableKernelModules = mkIf doEncryption [
        # I know aesni_intel exists, but does aesni_amd?
        "aesni_${config.custom.hardware.cpu}"
        "cryptd"
      ];
    };

    fileSystems = {
      "/" = {
        device = if cfg.root.isEncrypted then "/dev/mapper/root" else cfg.root.device;
        fsType = cfg.root.fsType;
      };
    } // (if (cfg.boot.mountPoint != null) then {
      "${cfg.boot.mountPoint}" = {
        inherit (cfg.boot) device fsType;
      };
    } else {});

    swapDevices = mkIf doSwap [
      { device = if doSwapEncryption then "/dev/mapper/swap" else cfg.swap.device; }
    ];
  }; 
}
