[
  ({ config, lib, pkgs, ... }:  let
    cfg = config.hardware.opengl.intelAcceleratedVideoPlayback;
  in {
    options.hardware.opengl.intelAcceleratedVideoPlayback = {
      enable = lib.mkEnableOption "Whether to enable Intel Accelerated Video Playback";
    };

    # https://nixos.wiki/wiki/Accelerated_Video_Playback
    config = lib.mkIf cfg.enable {
      nixpkgs.overlays = [(final: prev: {
        vaapiIntel = prev.vaapiIntel.override { enableHybridCodec = true; };
      })];

      hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

  })
]
