{
  stdenv,
  pkgs,
}: stdenv.mkDerivation {
  pname = "logout";
  version = "unstable";
  src = ./.;
  installPhase = let
    script = pkgs.writeShellScriptBin "logout" ''
      options=(
        "🪵 Logout"
        "🔒 Lock"
        "🌙 Suspend"
        "🧸 Hibernate"
        "🐤 Restart"
        "🪓 Shutdown"
        "Do Nothing"
      )

      choice=$(\
        printf '%s\n' "''${options[@]}" | \
        ${pkgs.rofi}/bin/rofi \
          -dmenu \
          -p Logout \
          -i \
      )

      choiceText="''${choice:2}"

      case "$choiceText" in
        Logout)    loginctl terminate-user $USER;;
        Lock)      swaylock;;
        Suspend)   systemctl suspend;;
        Hibernate) systemctl hibernate;;
        Restart)   systemctl reboot;;
        Shutdown)  systemctl poweroff;;
      esac
    '';
    desktopEntry = pkgs.writeText "logout.desktop" ''
    '';
  in ''
    mkdir $out;
    cp -r ${script}/* $out

    mkdir -p $out/share/applications

    cat > $out/share/applications/logout.desktop << EOF
    [Desktop Entry]
    Version=1.0
    Name=Logout
    GenericName=Logout options
    Terminal=false
    Type=Application
    Exec=$out/bin/logout
    EOF
  '';
}
