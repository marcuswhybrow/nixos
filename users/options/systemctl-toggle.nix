{ config, lib, helpers, ... }: let
  cfg = config.programs.systemctlToggle;
in {
  options.programs.systemctlToggle = {
    enable = lib.mkEnableOption "Whether to enable systemctl-toggle cli";
  };

  config = lib.mkIf cfg.enable {
    programs.fish.functions.systemctl-toggle = ''
      set command (if systemctl --user is-active $argv[1] > /dev/null; echo "stop"; else; echo "start"; end)
      systemctl --user $command $argv[1]
    '';
  };
}
