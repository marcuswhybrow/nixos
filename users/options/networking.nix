{ config, lib, pkgs, helpers, ... }: let
  cfg = config.programs.networking;
in {
  options.programs.networking = {
    enable = lib.mkEnableOption "Whether to enable networking cli";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi
      ripgrep

      (pkgs.writeShellScriptBin "networking" ''
        isWifiEnabled       () { [[ $(nmcli radio wifi) == enabled ]]; }
        isNetworkingEnabled () { [[ $(nmcli networking) == enabled ]]; }

        function toIcon () { [[ $? == 0 ]] && echo ✔️ || echo ▫️; }

        wifiAndEthernetIcon    () { isWifiEnabled && isNetworkingEnabled;     toIcon; }
        ethernetOnlyIcon       () { ! isWifiEnabled && isNetworkingEnabled;   toIcon; }
        networkingDisabledIcon () { ! isWifiEnabled && ! isNetworkingEnabled; toIcon; }

        options=(
          "$(wifiAndEthernetIcon) Wifi & Ethernet (nmcli networking on && nmcli radio wifi on)"
          "$(ethernetOnlyIcon) Ethernet Only (nmcli networking on && nmcli radio wifi off)"
          "$(networkingDisabledIcon) Disable All Networking (nmcli networking off && nmcli radio wifi off)"
          "Do Nothing"
        )

        ipAddress="$(\
          nmcli device show | \
          rg 'IP4.ADDRESS.* (([0-9]{1,3}\.){3}[0-9]{1,3})' \
            --only-matching \
            --replace '$1' \
            --max-count 1 \
        )"

        choice=$(\
          printf '%s\n' "''${options[@]}" | \
          rofi \
            -dmenu \
            -mesg "$ipAddress" \
            --case-sensitive \
            -p Networking \
        )

        command=$(echo -n $choice | rg "\((.*)\)" -or '$1')
        eval "$command"
      '')
    ];
  };
}
