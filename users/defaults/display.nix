[
  ({ config, lib, pkgs, helpers, ... }: let
    light = "${pkgs.light}/bin/light";
    fish = "${pkgs.fish}/bin/fish";
    dunstify = "${pkgs.dunst}/bin/dunstify";
  in {
    options.custom.users = helpers.options.mkForEachUser {
      display.brightness.step = helpers.options.mkInt 5;
    };

    config.programs.light.enable = true;

    config.home-manager.users = helpers.config.mkForEachUser config (user: {
      home.packages = [
        pkgs.fish
        pkgs.dunst
      ];

      wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
        XF86MonBrightnessUp = ''exec fish -c "@brightness up"'';
        XF86MonBrightnessDown = ''exec fish -c "@brightness down"'';
      };

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
    });
  })
]
