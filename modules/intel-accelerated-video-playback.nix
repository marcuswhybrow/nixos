{ config, lib, pkgs, ... }:  let
  cfg = config.hardware.graphics.intelAcceleratedVideoPlayback;
in {
  options.hardware.graphics.intelAcceleratedVideoPlayback = {
    enable = lib.mkEnableOption "Whether to enable Intel Accelerated Video Playback";
  };

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [(final: prev: {
      vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
    })];

    hardware.graphics = {
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
