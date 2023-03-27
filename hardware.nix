{ config, pkgs, lib, ... }: let
  inherit (lib) mkDefault mkOption types mkIf;
  cfg = config.custom.hardware;
  isIntel = cfg.cpu == "intel";
in {
  options.custom.hardware = {
    cpu = mkOption { type = types.enum [ "intel" "amd" ]; };
  };

  config = {
    hardware.enableRedistributableFirmware = mkDefault true;
    hardware.cpu.${cfg.cpu} = {
      updateMicrocode = mkDefault true;
      sgx.provision.enable = isIntel; 
    };

    # https://nixos.wiki/wiki/Accelerated_Video_Playback
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = true;
      };
    };
    hardware.opengl = mkIf isIntel {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
