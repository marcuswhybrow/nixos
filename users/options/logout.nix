{ config, lib, pkgs, helpers, ... }: let
  cfg = config.programs.logout;
in {
  options.programs.logout = {
    enable = lib.mkEnableOption "Whether to enable logout cli";
  };

  config = lib.mkIf cfg.enable {
    # TODO Remove dependencies
    home.packages = with pkgs; [
      rofi
      ripgrep
      fish
    ];

    programs.fish.functions.logout = ''
      string join \n \
        "🪵 Logout (loginctl terminate-user $USER)" \
        "🔒 Lock (swaylock)" \
        "🌙 Suspend (systemctl suspend)" \
        "🧸 Hibernate (systemctl hibernate)" \
        "🐤 Restart (systemctl reboot)" \
        "🪓 Shutdown (systemctl poweroff)" \
        "Do Nothing" | \
      rofi \
        -dmenu \
        -p Logout | \
      rg "\((.*)\)" -or '$1' | \
      fish
    '';
  };
}
