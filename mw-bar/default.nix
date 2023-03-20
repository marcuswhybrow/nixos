{ pkgs, lib, config, ...}:

let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.mwBar;
  alacrittyCmd = "${pkgs.alacritty}/bin/alacritty --command";
  htop = "${pkgs.htop}/bin/htop";
  wlogout = "${pkgs.wlogout}/bin/wlogout";
  pamixer = "${pkgs.pamixer}/bin/pamixer";
in {
  options.mwBar.enable = mkEnableOption "Marcus' WayBar config";

  config = mkIf cfg.enable {
    home-manager.users.marcus.programs.waybar = {
      enable = true;
      style = builtins.readFile ./style.css;
      systemd.enable = true;
      settings.mainBar = {
        layer = "bottom";
        position = "top";
        height = 30;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [];
        modules-right = [
          "tray"
          "network"
          "cpu"
          "memory"
          "temperature"
          "disk"
          "pulseaudio"
          "battery"
          "clock#year"
          "clock#month"
          "clock#day"
          "clock#hour"
          "clock#minute"
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

        pulseaudio = {
          format = "{volume:03}";
          format-bluetooth = "{volume:03}";
          format-muted = "<span strikethrough=\"true\" strikethrough_color=\"white\">{volume:03}</span>";
          on-click = "exec ${pamixer} --toggle-mute";
          on-click-right = "exec ${pamixer} --set-volume 100";
          scroll-step = 5;
        };

        battery = {
          format = "{capacity:03}";
          tooltip-format = "Batter {timeTo}";
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
        };

        "clock#year"   = { tooltip = false; format = "{:%Y}"; };
        "clock#month"  = { tooltip = false; format = "{:%m}"; };
        "clock#day"    = { tooltip = false; format = "{:%d}"; };
        "clock#hour"   = { tooltip = false; format = "{:%H}"; };
        "clock#minute" = { tooltip = false; format = "{:%M}"; };

        "custom/logout" = {
          format = "⏻";
          tooltip = false;
          on-click = "exec ${wlogout}";
        };

      };
    };
  };
}
