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

      choiceText="''${choice:3}"

      case "$choiceText" in
        Logout)    loginctl terminate-user $USER;;
        Lock)      swaylock;;
        Suspend)   systemctl suspend;;
        Hibernate) systemctl hibernate;;
        Restart)   systemctl reboot;;
        Shutdown)  systemctl poweroff;;
      esac
    '';
  in ''
    mkdir $out;
    cp -r ${script}/* $out
  '';
}
