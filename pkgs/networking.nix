{
  pkgs,

  rofi ? pkgs.rofi,
}: pkgs.runCommand "networking" {} (let
  script = pkgs.writeScript "networking" (let
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
  in ''
    options=(
      "Wifi"
      "Ethernet"
      "Disable"
    )

    choice="$(\
      printf '%s\n' "''${options[@]}" | \
      ${rofi}/bin/rofi -dmenu -i -theme-str 'entry { placeholder: "Networking"; }' \
    )"

    case $choice in
      Wifi)
        ${nmcli} networking on
        ${nmcli} radio wifi on
        notifyMsg="Switching to Wifi"
        ;;
      Ethernet)
        ${nmcli} networking on
        ${nmcli} radio wifi off
        notifyMsg="Switching to Ethernet"
        ;;
      Disable)
        ${nmcli} radio wifi off
        ${nmcli} networking off
        notifyMsg="Disabling Networking"
        ;;
      *) exit 1;;
    esac

    ${pkgs.libnotify}/bin/notify-send \
      --app-name networking \
      --urgency normal \
      --expire-time 2000 \
      --hint string:x-dunst-stack-tag:networking \
      "$notifyMsg"
  '');
in ''
  mkdir -p $out/bin
  ln -s ${script} $out/bin/networking

  mkdir -p $out/share/applications
  tee $out/share/applications/networking.desktop << EOF
  [Desktop Entry]
  Version=1.0
  Name=Networking
  GenericName=Turn WiFi and Ethernet on or off
  Terminal=false
  Type=Application
  Exec=$out/bin/networking
  EOF
'')
