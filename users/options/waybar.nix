{ config, lib, pkgs, types, ... }: let
  cfg = config.programs.waybar.marcusBar;
in {
  options.programs.waybar.marcusBar = {
    enable = lib.mkEnableOption "Whether to enable Marcus' waybar style.";

    network.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    cpu.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    memory.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    disk.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    logout.onClick = lib.mkOption { type = with types; nullOr str; default = null; };
    date.onClick = lib.mkOption { type = with types; nullOr str; default = null; };

    colors = {
      primary = lib.mkOption { type = types.str; default = "#cccccc"; };
    };
  };

  config = let
    # I want to use the glyphsfrom Font Awesome, but use a different font for text.
    # Waybar used Pango Markup (https://docs.gtk.org/Pango/pango_markup.html)
    # Pango will try differnt fonts until a gylph is found.
    # However Awesome Font and Nerd Fonts complete for some glyphs.
    # Pango has no way way to specify a CSS class for styling later.
    # So I'm using a nix function to explicity use Font Awesome for icons.
    icon = text: ''<span color="${cfg.colors.primary}" font_family="Font Awesome 6 Free">${text}</span>'';
  in lib.mkIf cfg.enable {
    home.packages = with pkgs; [ font-awesome ];
    fonts.fontconfig.enable = true;

    # https://github.com/Alexays/Waybar/wiki/Configuration
    programs.waybar.settings.mainBar = {
      layer = lib.mkDefault "top";
      position = lib.mkDefault "bottom";
      mode = lib.mkDefault "hide";
      ipc = lib.mkDefault true;
      margin = "100 100";
      height = null;
      width = null;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
        "tray"
      ];
      modules-center = [
        "network"
        "cpu"
        "memory"
        "temperature"
        "disk"
        "battery"
      ];
      modules-right = [
        "clock#date"
        "clock#time"
      ];

      tray = {
        icon-size = 21;
        spacing = 10;
      };


      # https://github.com/Alexays/Waybar/wiki/Module:-Network
      network = {
        interval = 1;

        format = "${icon ""} Disabled";
        tooltip = "Networking disabled";

        format-wifi = "${icon ""} {signalStrength:02}%";
        tooltip-format-wifi = "{essid} {signalStrength}% {ipaddr}";

        format-ethernet = "${icon ""} Eth";
        tooltip-format-ethernet = "Ethernet {ipaddr}";

        format-disconnected = "${icon ""} Disconnected";
        tooltip-format-disconnected = "Disconnected";

        on-click = lib.mkIf (cfg.network.onClick != null) "exec ${cfg.network.onClick}";
      };

      cpu = {
        format = "${icon ""} {usage:02}%";
        interval = 1;
        on-click = "exec ${cfg.cpu.onClick}";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      memory = {
        interval = 1;
        format = ''${icon ""} {percentage:02}%'';
        on-click = lib.mkIf (cfg.memory.onClick != null) "exec ${cfg.memory.onClick}";
        tooltip-format = "{used:0.1f}/{total:0.1f}GB RAM";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      temperature = {
        interval = 1;
        format = "${icon ""} {temperatureC:02}°C";
        tooltip-format = "{temperatureC}°C";
        critical-threshold = 80;
      };

      disk = {
        interval = 60;
        format = "${icon ""} {percentage_used:02}%";
        tooltip-format = "{used} of {total} SSD";
        on-click = lib.mkIf (cfg.disk.onClick != null) ''exec ${cfg.disk.onClick}'';
      };

      # https://github.com/Alexays/Waybar/wiki/Module:-Battery
      battery = {
        interval = 1;
        format = "${icon ""} {capacity:02}%";
        tooltip-format = "{timeTo}";

        format-charging = "${icon ""} {capacity:02}%";
        tooltip-format-charging = "{timeTo}";

        format-discharging = "${icon ""} {capacity:02}%";
        tooltip-format-discharging = "{timeTo}";

        states = {
          good = 95;
          warning = 20;
          critical = 10;
        };
      };

      "clock#date" = {
        tooltip = false;

        # https://fmt.dev/dev/syntax.html#chrono-specs
        format = "{:%d %b %Y}";
        on-click = lib.mkIf (cfg.date.onClick != null) ''exec ${cfg.date.onClick}'';
      };
      "clock#time" = {
        tooltip = false;
        format = "{:%H:%M}";
      };

      "sway/mode" = {
        format = "<sup>{}</sup>";
      };
    };

    # https://github.com/Alexays/Waybar/wiki/Styling
    # Uses GTK CSS (https://docs.gtk.org/gtk3/css-properties.html)
    programs.waybar.style = let
      primaryColor = cfg.colors.primary;
      warning= "#ff8800";
      critical = "#ff0000";
    in ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
      }
      #waybar {
        color: #000000;
        font-family: "FiraCode Nerd Font";
        font-size: 18px;

        background: rgba(255,255,255,0.96);
        border-radius: 4px;
        border: 4px solid ${primaryColor};
      }
      .warning { color: ${warning}; }
      .critical { color: ${critical}; }

      #network, #cpu, #memory, #temperature,
      #disk, #pulseaudio, #battery, #clock,
      #custom-logout, #workspaces, #tray,
      #mode {
        background: transparent;
        padding: 0;
        margin: 25px 15px;
      }

      #workspaces {
        background: transparent;
        margin-left: 25px;
        margin-right: 0;
      }

      #mode {
        font-size: 12px;
        margin-right: 0;
        background: #ff0000;
        border-radius: 4px;
        color: #ffffff;
        font-weight: bold;
        padding: 0 5px;
      }

      #clock.date {
        color: ${primaryColor};
      }
      #clock.time {
        margin-left: 0;
        margin-right: 25px;
      }

      #memory .icon {
        color: red;
      }

      #battery.charging { color: green; }

      #workspaces button {
        border-top: 2px solid transparent;
        color: ${primaryColor};
        margin: 0;
        padding: 0;
      }
      #workspaces button:hover {
        border-top: 2px solid transparent;
        color: #000000;
        font-weight: bold;
      }
      #workspaces button.focused {
        color: #000000;
        font-weight: bold;
      }
      #workspaces button.urgent {
        color: #ff8800;
      }
    '';
  };
}
