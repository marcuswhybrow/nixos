{ config, lib, pkgs, ... }: let
  cfg = config.programs.systemctlToggle;
in {
  options.programs.systemctlToggle = {
    enable = lib.mkEnableOption "Whether to enable systemctl-toggle cli";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "systemctl-toggle" ''
        command=$(systemctl --user is-active $1 > /dev/null && echo "stop" || echo "start")
        systemctl --user $command $1
      '')
    ];
  };
}
