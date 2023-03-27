{ config, lib, pkgs, ... }: let
  inherit (lib) mkOption types mkDefault;
  cfg = config.custom.platform;
in {
  options.custom.platform = mkOption { type = types.str; };
  config.nixpkgs = {
    hostPlatform = mkDefault cfg;
    config.allowUnfree = true;
  };
}
