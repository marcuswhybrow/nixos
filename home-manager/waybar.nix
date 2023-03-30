{ pkgs, lib, config, ...}:

let
  inherit (lib) mkEnableOption mkIf mkOption types mkDefault;
  utils = import ../utils { inherit lib; };
  inherit (builtins) readFile;

  # Assume the alacritty, htop, wlogout, and pamixer, fish
  # TODO: Use options instead
  alacrittyCmd = "${pkgs.alacritty}/bin/alacritty --command";
  htop = "${pkgs.htop}/bin/htop";
  rofi = "${pkgs.rofi}/bin/rofi";
  pamixer = "${pkgs.pamixer}/bin/pamixer";
  fish = "${pkgs.fish}/bin/fish";
in {
  options.custom.users = utils.options.mkForEachUser {
    waybar.enable = mkEnableOption "Marcus' Waybar config";
  };

  config.home-manager.users = utils.config.mkForEachUser config (user: {
    home.packages = [
      pkgs.fish
      pkgs.ripgrep
      pkgs.rofi
    ];

    xdg.configFile."fish/functions/@logout.fish".text = ''
      function @logout
        echo "\
        🔒 Lock (swaylock)
        🪵 Logout (loginctl terminate-user $USER)
        🌙 Suspend (systemctl suspend)
        🧸 Hibernate (systemctl hibernate)
        🐤 Restart (systemctl reboot)
        🪓 Shutdown (systemctl poweroff)
        Do Nothing" | \
        rofi \
          -dmenu \
          -p Logout | \
        rg "\((.*)\)" -or '$1' | \
        fish
      end
    '';

    programs = mkIf user.waybar.enable {
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
            format-ethernet = "{ipaddr}";
            format-disconnected = "0.0.0.0";
            on-click = "exec ${pkgs.sway}/bin/swaynag -m 'Networking'";
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
}
