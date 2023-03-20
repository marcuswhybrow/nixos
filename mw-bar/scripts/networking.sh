declare -a options=(
	"WiFi On - nmcli radio wifi on"
	"WiFi Off - nmcli radio wifi off"
	"Networking On - nmcli networking on"
	"Networking Off - nmcli networking off"
)
choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p 'Networking')
cmd=$(echo "${choice}" | awk '{print $NF}')
exec /run/current-system/sw/bin/${cmd}
