[
  ({ config, lib, pkgs, helpers, ... }: let
    # Assume the alacritty, htop, wlogout, and pamixer, fish
    # TODO: Use options instead
    alacrittyCmd = "${pkgs.alacritty}/bin/alacritty --command";
    htop = "${pkgs.htop}/bin/htop";
    rofi = "${pkgs.rofi}/bin/rofi";
    pamixer = "${pkgs.pamixer}/bin/pamixer";
    fish = "${pkgs.fish}/bin/fish";
  in {
    options.custom.users = helpers.options.mkForEachUser {
      waybar.enable = lib.mkEnableOption "Marcus' Waybar config";
    };

    config.home-manager.users = helpers.config.mkForEachUser config (user: {
      home.packages = [
        pkgs.fish
        pkgs.ripgrep
        pkgs.rofi
      ];

      xdg.configFile."fish/functions/@logout.fish".text = ''
        function @logout
          string join \n \
            "🪵 Logout (loginctl terminate-user $USER)" \
            "🔒 Lock (swaylock)" \
            "🌙 Suspend (systemctl suspend)" \
            "🧸 Hibernate (systemctl hibernate)" \
            "🐤 Restart (systemctl reboot)" \
            "🪓 Shutdown (systemctl poweroff)" \
            "Do Nothing" | \
          rofi \
            -dmenu \
            -p Logout | \
          rg "\((.*)\)" -or '$1' | \
          fish
        end
      '';

      xdg.configFile."fish/functions/@networking.fish".text = ''
        function @networking
          if test (nmcli radio wifi) = "enabled"
            set wifiOption "✅ Wifi (nmcli radio wifi off)"
          else
            set wifiOption "❌ Wifi (nmcli networking on && nmcli radio wifi on)"
          end

          if test (nmcli networking) = "enabled"
            set networkingOption "✅ Networking (nmcli radio wifi off && nmcli networking off)"
          else
            set networkingOption "❌ Networking (nmcli networking on)"
          end

          set ipAddress "$(nmcli device show | \
          rg 'IP4.ADDRESS.* (([0-9]{1,3}\.){3}[0-9]{1,3})' \
            --only-matching \
            --replace '$1' \
            --max-count 1)"

          set message $ipAddress

          string join \n \
            "$wifiOption" \
            "$networkingOption" \
            "Do Nothing" | \
          rofi \
            -dmenu \
            -mesg "$message" \
            -p Networking | \
          rg "\((.*)\)" -or '$1' | \
          fish
        end
      '';

      programs = lib.mkIf user.waybar.enable {
        waybar = {
          enable = true;
          systemd.enable = true;
          settings.mainBar = {
            layer = "bottom";
            position = "top";
            height = 30;

            modules-left = [
              "clock"
            ];
            modules-center = [
              "sway/workspaces"
              "sway/mode"
            ];
            modules-right = [
              "tray"
              "network"
              "cpu"
              "memory"
              "temperature"
              "disk"
              "battery"
              "custom/logout"
            ];

            tray = {
              icon-size = 21;
              spacing = 10;
            };

            network = {
              interval = 5;
              format-wifi = "{essid} {signalStrength}% {ipaddr}";
              format-ethernet = "Wired {ipaddr}";
              format-disconnected = "0.0.0.0";
              on-click = ''exec ${fish} -c "@networking"'';
            };

            cpu = {
              format = "{usage:03}";
              interval = 5;
              on-click = "exec ${alacrittyCmd} ${htop} --sort-key=PERCENT_CPU";
              states = {
                warning = 70;
                critical = 90;
              };
            };

            memory = {
              interval = 5;
              format = "{percentage:03}";
              on-click = "exec ${alacrittyCmd} ${htop} --sort-key=PERCENT_MEM";
              tooltip-format = "{used:0.1f}/{total:0.1f}GB RAM";
              states = {
                warning = 70;
                critical = 90;
              };
            };

            temperature = {
              interval = 5;
              format = "{temperatureC:03}";
              tooltip-format = "{temperatureC}°C";
              critical-threshold = 80;
            };

            disk = {
              interval = 60;
              format = "{percentage_free:03}";
              tooltip-format = "{used} of {total} SSD";
              on-click = "exec ${alacrittyCmd} ${htop} --sort-key=IO_RATE";
            };

            battery = {
              format = "{capacity:03}";
              tooltip-format = "Battery {timeTo}";
              states = {
                good = 95;
                warning = 30;
                critical = 15;
              };
            };

            "clock" = {
              tooltip = false;
              format = "{:%Y-%m-%d %H:%M}";
            };

            "custom/logout" = {
              format = "⏻";
              tooltip = false;
              on-click = ''exec ${fish} -c "@logout"'';
            };
          };

        };
      };
    });
  })
]
