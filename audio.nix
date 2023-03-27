{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.audio;
in {
  options.custom.audio.enable = mkEnableOption "Enable audio";
  config = mkIf cfg.enable {
    sound.enable = true;
    sound.mediaKeys.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
    };
    environment.systemPackages = [ pkgs.pamixer ];
  };
}

