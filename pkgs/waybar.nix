{
  pkgs,
  stdenv,
  makeBinaryWrapper,
  lib,

  primaryColor ? "#000000",
  warningColor ? "#ff8800",
  criticalColor ? "#ff0000",
  extraConfig ? {},
  iconFont ? "Font Awesome 6 Free",
}: let
  inherit (lib) recursiveUpdate;
  inherit (builtins) toJSON;

  config = let
    # I want to use the glyphsfrom Font Awesome, but use a different font for text.
    # Waybar used Pango Markup (https://docs.gtk.org/Pango/pango_markup.html)
    # Pango will try differnt fonts until a gylph is found.
    # However Awesome Font and Nerd Fonts complete for some glyphs.
    # Pango has no way way to specify a CSS class for styling later.
    # So I'm using a nix function to explicity use a different font for icons.
    icon = text: ''<span color="${primaryColor}" font_family="${iconFont}">${text}</span>'';

    baseConfig = {
      layer = "top";
      position = "bottom";
      mode = "hide";
      ipc = true;
      margin = "100 100";
      height = null;
      width = null;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
        "tray"
      ];

      modules-center = [
        "custom/wifi-alarm"
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
      };

      "custom/wifi-alarm" = {
        # This detmines if the WiFi radio is one, when the connection is not a wireless interface
        # Ref: https://unix.stackexchange.com/questions/260235/command-to-detect-if-internet-connection-is-wired-or-wireless
        exec = ''
          ip route get 8.8.8.8 2> /dev/null | \
          grep -Po 'dev \K\w+' | \
           grep -qFf - /proc/net/wireless \
          || [[ $(nmcli radio wifi) == enabled ]] \
          && echo '⚠️'
        '';
        interval = 5;
      };

      cpu = {
        format = "${icon ""} {usage:02}%";
        interval = 1;
        states = {
          warning = 70;
          critical = 90;
        };
      };

      memory = {
        interval = 1;
        format = ''${icon ""} {percentage:02}%'';
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
      };

      "clock#time" = {
        tooltip = false;
        format = "{:%H:%M}";
      };

      "sway/mode" = {
        format = "<sup>{}</sup>";
      };
    };
  in pkgs.writeText "waybar-config.json" (toJSON (recursiveUpdate baseConfig extraConfig));

  style = pkgs.writeText "waybar-style.css" ''
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
    .warning { color: ${warningColor}; }
    .critical { color: ${criticalColor}; }

    #network, #cpu, #memory, #temperature,
    #disk, #pulseaudio, #battery, #clock,
    #custom-logout, #workspaces, #tray,
    #mode {
      background: transparent;
      padding: 0;
      margin: 25px 15px;
    }

    #custom.wifi-alarm {

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

  # system d
in stdenv.mkDerivation {
  pname = "waybar";
  version = "unstable";
  src = ./.;

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r ${pkgs.waybar}/share $out/
    cp ${config} $out/config
    cp ${style} $out/style.css
    makeWrapper ${pkgs.waybar}/bin/waybar $out/bin/waybar \
      --add-flags "--config ${config} --style ${style}"
  '';
}
