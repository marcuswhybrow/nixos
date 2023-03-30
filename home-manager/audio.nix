{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  utils = import ../utils { inherit lib; };
  pamixer = "${pkgs.pamixer}/bin/pamixer";
in {
  options.custom.users = utils.options.mkForEachUser {
    audio.step = utils.options.mkInt 5;
  };

  config = {
    home-manager.users = utils.config.mkForEachUser config (user: {
      home.packages = [
        pkgs.pamixer
      ];
      wayland.windowManager.sway.config = {
        keybindings = lib.mkOptionDefault (let 
          step = utils.smartStep "${pamixer} --get-volume" user.audio.step;
        in {
          XF86AudioMute = utils.exec "${pamixer} --toggle-mute";
          XF86AudioLowerVolume = utils.exec "${pamixer} --decrease ${step}";
          XF86AudioRaiseVolume = utils.exec "${pamixer} --increase ${step}";
          XF86AudioPrev = utils.exec "";
          XF86AudioPlay = utils.exec "";
          XF86AudioNext = utils.exec "";
        });
      };
    });

    sound.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
    };
  };
}
