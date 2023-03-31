{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types;
  cfg = config.custom;
in {
  options.custom = {
    stateVersion = mkOption { type = types.str; };
    packages = mkOption { type = with types; listOf package; default = []; };
  };

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = cfg.stateVersion;
    environment.systemPackages = cfg.packages;
  };
}
