{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  utils = import ../utils { inherit lib; };
  pamixer = "${pkgs.pamixer}/bin/pamixer";
in {
  options.custom.users = utils.options.mkForEachUser {
    audio.volume = {
      step = utils.options.mkInt 5;
      unmuteOnChange = utils.options.mkTrue;
    };
  };

  config = {
    home-manager.users = utils.config.mkForEachUser config (user: {
      home.packages = [
        pkgs.pamixer
        pkgs.fish
      ];

      xdg.configFile."fish/functions/@volume.fish".text = let
        inherit (user.audio.volume) step unmuteOnChange;
      in ''
        function @volume
          switch (pamixer --get-volume)
            case 0
              set step 1
            case 1
              set step ${toString (step - 1)}
            case '*'
              set step ${toString step}
          end

          switch $argv[1]
            case up
              pamixer ${if unmuteOnChange then "--unmute" else ""} --increase $step
            case down
              pamixer ${if unmuteOnChange then "--unmute" else ""} --decrease $step
            case toggle-mute
              pamixer --toggle-mute
          end

          set vol (pamixer --get-volume)
          set mute (pamixer --get-mute)
          set tag volume

          if test $vol = "0"; or test $mute = "true"
            dunstify \
              --appname changeVolume \
              --urgency low \
              --icon audio-volume-muted \
              --hints string:x-dunst-stack-tag:$tag \
              "Volume muted"
          else
            dunstify \
              --appname changeVolume \
              --urgency low \
              --icon audio-volume-high \
              --hints string:x-dunst-stack-tag:$tag \
              --hints int:value:$vol \
              --timeout 2000 \
              "Volume: $vol%"
          end
        end
      '';

      wayland.windowManager.sway.config = {
        keybindings = lib.mkOptionDefault (let 
          step = utils.smartStep "${pamixer} --get-volume" user.audio.step;
        in {
          XF86AudioMute = ''exec fish -c "@volume toggle-mute"'';
          XF86AudioLowerVolume = ''exec fish -c "@volume down"'';
          XF86AudioRaiseVolume = ''exec fish -c "@volume up"'';
          XF86AudioPrev = ''exec'';
          XF86AudioPlay = ''exec'';
          XF86AudioNext = ''exec'';
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
