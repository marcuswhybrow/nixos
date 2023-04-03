{ config, lib, helpers, ... }: let
  cfg = config.programs.waybar.marcusBar;
in { 
  options.programs.waybar.marcusBar = {
    enable = lib.mkEnableOption "Whether to enable Marcus' waybar style.";
    network.onClick = lib.mkOption { type = lib.types.str; };
    cpu.onClick = lib.mkOption { type = lib.types.str; };
    memory.onClick = lib.mkOption { type = lib.types.str; };
    disk.onClick = lib.mkOption { type = lib.types.str; };
    logout.onClick = lib.mkOption { type = lib.types.str; };
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

      network = {
        interval = 5;
        format-wifi = "{essid} {signalStrength}% {ipaddr}";
        format-ethernet = "Wired {ipaddr}";
        format-disconnected = "0.0.0.0";
        on-click = "exec ${cfg.network.onClick}";
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
        on-click = "exec ${cfg.memory.onClick}";
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
        on-click = ''exec ${cfg.disk.onClick}'';
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
        on-click = ''exec ${cfg.logout.onClick}'';
      };
    };
  };
}
