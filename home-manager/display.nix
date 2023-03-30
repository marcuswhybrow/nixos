{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf mkDefault mkOptionDefault;
  inherit (builtins) mapAttrs toString;
  utils = import ../utils { inherit lib; };
  light = "${pkgs.light}/bin/light";
  fish = "${pkgs.fish}/bin/fish";
  dunstify = "${pkgs.dunst}/bin/dunstify";
in {
  options.custom.users = utils.options.mkForEachUser {
    display.brightness = {
      step = utils.options.mkInt 5;
    };
  };

  config = {
    programs.light.enable = true;

    home-manager.users = utils.config.mkForEachUser config (user: {
      home.packages = [
        pkgs.fish
        pkgs.dunst
      ];

      xdg.configFile."fish/functions/@brightness.fish".text = ''
        function @brightness
          switch (light -G)
            case 0.00
              set step 1
            case 1.00
              set step ${toString (user.display.brightness.step - 1)}
            case '*'
              set step ${toString user.display.brightness.step}
          end

          switch $argv[1]
            case up
              light -A $step
            case down
              light -U $step
            case '*'
              light -G
          end

          set val (light -G)

          dunstify \
            --appname changeBrightness \
            --urgency low \
            --hints string:x-dunst-stack-tag:brightness \
            --hints int:value:$val \
            --timeout 1000 \
            "Brightness $val%"
        end
      '';

      wayland.windowManager.sway.config.keybindings = mkOptionDefault {
        XF86MonBrightnessUp = ''exec fish -c "@brightness up"'';
        XF86MonBrightnessDown = ''exec fish -c "@brightness down"'';
      };
    });
  };
}
