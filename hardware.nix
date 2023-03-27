{ config, pkgs, lib, ... }: let
  inherit (lib) mkDefault mkOption types;
  cfg = config.custom.hardware;
in {
  options.custom.hardware = {
    cpu = mkOption { type = types.enum [ "intel" "amd" ]; };
  };

  config = {
    hardware.enableRedistributableFirmware = mkDefault true;
    hardware.cpu.${cfg.cpu} = {
      updateMicrocode = mkDefault true;
      sgx.provision.enable = cfg.cpu == "intel";
    };
  };
}
