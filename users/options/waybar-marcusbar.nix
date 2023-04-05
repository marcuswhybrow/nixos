{ config, lib, types, helpers, ... }: let
  cfg = config.programs.waybar.marcusBar;
in { 
  options.programs.waybar.marcusBar = {
    enable = lib.mkEnableOption "Whether to enable Marcus' waybar style.";
    network.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    cpu.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    memory.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    disk.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    logout.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
  };

  config = lib.mkIf cfg.enable {
    programs.waybar.settings.mainBar = {
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


      # https://github.com/Alexays/Waybar/wiki/Module:-Network
      network = {
        interval = 1;

        format = "127.0.0.1";
        tooltip = "Networking disabled";

        format-wifi = "⚠️ {ipaddr}";
        tooltip-format-wifi = "{essid} {signalStrength}% {ipaddr}";

        format-ethernet = "{ipaddr}";
        tooltip-format-ethernet = "Ethernet {ipaddr}";

        format-disconnected = "127.0.0.1";
        tooltip-format-disconnected = "Disconnected";

        on-click = lib.mkIf (cfg.network.onClick != null) "exec ${cfg.network.onClick}";
      };

      cpu = {
        format = "{usage:03}";
        interval = 5;
        on-click = "exec ${cfg.cpu.onClick}";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      memory = {
        interval = 5;
        format = "{percentage:03}";
        on-click = lib.mkIf (cfg.memory.onClick != null) "exec ${cfg.memory.onClick}";
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
        on-click = lib.mkIf (cfg.disk.onClick != null) ''exec ${cfg.disk.onClick}'';
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
        on-click = lib.mkIf (cfg.logout.onClick != null) ''exec ${cfg.logout.onClick}'';
      };
    };
  };
}
