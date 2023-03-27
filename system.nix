{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types;
  cfg = config.custom;
in {
  options.custom = {
    packages = mkOption { type = with types; listOf package; default = []; };
    programs = mkOption { type = types.attrs; default = {}; };
    services = mkOption { type = types.attrs; default = {}; };
    stateVersion = mkOption { type = types.str; };
  };

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = cfg.stateVersion;
    environment.systemPackages = cfg.packages;
    inherit (cfg) programs services;
  };
}
