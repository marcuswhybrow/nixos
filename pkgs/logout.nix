{
  pkgs,

  rofi ? pkgs.rofi,
}: pkgs.runCommand "logout" {} (let
  script = pkgs.writeScript "logout" ''
    options=(
      "🪵 Logout"
      "🔒 Lock"
      "🌙 Suspend"
      "🧸 Hibernate"
      "🐤 Restart"
      "🪓 Shutdown"
    )

    choice=$(\
      printf '%s\n' "''${options[@]}" | \
      ${rofi}/bin/rofi \
        -dmenu \
        -theme-str 'entry { placeholder: "Logout"; }' \
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
in ''
  mkdir -p $out/bin
  ln -s ${script} $out/bin/logout

  mkdir -p $out/share/applications
  tee $out/share/applications/logout.desktop << EOF
  [Desktop Entry]
  Version=1.0
  Name=Logout
  GenericName=Logout options
  Terminal=false
  Type=Application
  Exec=$out/bin/logout
  EOF
'')
