#!/run/current-system/sw/bin/fish

set option (echo "WiFi On,WiFi Off,Networking On,Networking Off," | rofi -sep ',' -dmenu -i -p "Networking")

switch "$option"
  case "WiFi On"
    exec nmcli networking on
    exec nmcli radio wifi on
  case "WiFi Off"
    exec nmcli radio wifi off
  case "Networking On"
    exec nmcli networking on
  case "Networking Off"
    exec nmcli networking off
end
