[
  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  ({ config, lib, pkgs, ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        vaapiIntel = prev.vaapiIntel.override {
          enableHybridCodec = true;
        };
      })
    ];

    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  })
]
