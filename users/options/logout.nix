{ config, lib, pkgs, helpers, ... }: let
  cfg = config.programs.logout;
in {
  options.programs.logout = {
    enable = lib.mkEnableOption "Whether to enable logout cli";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi
      ripgrep
      (pkgs.writeShellScriptBin "logout" ''
        options=(
          "🪵 Logout (loginctl terminate-user $USER)"
          "🔒 Lock (swaylock)"
          "🌙 Suspend (systemctl suspend)"
          "🧸 Hibernate (systemctl hibernate)"
          "🐤 Restart (systemctl reboot)"
          "🪓 Shutdown (systemctl poweroff)"
          "Do Nothing"
        )
        choice=$(printf '%s\n' "''${options[@]}" | rofi -dmenu -p Logout)
        cmd=$(echo -n $choice | rg "\((.*)\)" -or '$1')
        $cmd
      '')
    ];
  };
}
