{ config, lib, pkgs, helpers, ... }: let
  cfg = config.programs.networking;
in {
  options.programs.networking = {
    enable = lib.mkEnableOption "Whether to enable networking cli";
  };

  config = lib.mkIf cfg.enable {
    # TODO Remove dependencies
    home.packages = with pkgs; [
      rofi
      ripgrep
      fish
    ];

    programs.fish.functions.networking = ''
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
    '';
  };
}
