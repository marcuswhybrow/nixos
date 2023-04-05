{
  description = "A ROFI interface to nmcli";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      default = self.packages.${system}.networking;
      networking = pkgs.stdenv.mkDerivation {
        pname = "networking";
        version = "2023-04-04";
        name = "networking";
        src = ./.;
        installPhase = let
          nmcli = "${pkgs.networkmanager}/bin/nmcli";
          rofi = "${pkgs.rofi}/bin/rofi";
          rg = "${pkgs.ripgrep}/bin/rg";
          script = pkgs.writeShellScriptBin "networking" ''
            isWifiEnabled       () { [[ $(${nmcli} radio wifi) == enabled ]]; }
            isNetworkingEnabled () { [[ $(${nmcli} networking) == enabled ]]; }

            function toIcon () { [[ $? == 0 ]] && echo '✔️' || echo '▫️'; }

            wifiAndEthernetIcon    () { isWifiEnabled && isNetworkingEnabled;     toIcon; }
            ethernetOnlyIcon       () { ! isWifiEnabled && isNetworkingEnabled;   toIcon; }
            networkingDisabledIcon () { ! isWifiEnabled && ! isNetworkingEnabled; toIcon; }

            ipAddress="$(\
              ${nmcli} device show | \
              ${rg} 'IP4.ADDRESS.* (([0-9]{1,3}\.){3}[0-9]{1,3})' \
                --only-matching \
                --replace '$1' \
                --max-count 1 \
            )"

            message=$ipAddress

            if isWifiEnabled; then
              message+=" ⚠️ Wifi"
            fi

            options=(
              "$(wifiAndEthernetIcon) Wifi & Ethernet"
              "$(ethernetOnlyIcon) Ethernet Only"
              "$(networkingDisabledIcon) Disable All Networking"
              "Do Nothing"
            )

            choice="$(\
              printf '%s\n' "''${options[@]}" | \
              ${rofi} -dmenu -mesg "$message" -i -p Networking \
            )"

            choiceWithoutIcon="''${choice:3}"

            case $choiceWithoutIcon in
              "Wifi & Ethernet")
                ${nmcli} networking on
                ${nmcli} radio wifi on
                ;;
              "Ethernet Only")
                ${nmcli} networking on
                ${nmcli} radio wifi off
                ;;
              "Disable All Networking")
                ${nmcli} radio wifi off
                ${nmcli} networking off
                ;;
            esac
          '';
        in ''
          mkdir $out;
          cp -r ${script}/* $out
        '';
      };
    });

    nixosModules.networking = { pkgs, ... }: {
      nixpkgs.overlays = [ self.overlay ];
    };

    overlay = final: prev: {
      networking = self.packages.${final.system}.networking;
    };
  };
}
