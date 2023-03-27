{ config , lib, pkgs, ... }: let
  inherit (lib) mkOption types;
  inherit (builtins) mapAttrs;
  cfg = config.custom.users;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options = {
      fullName = mkOption { type = types.str; };
      groups = mkOption { type = with types; listOf str; };
      shell = mkOption { type = types.package; };
      packages = mkOption { type = with types; listOf package; };
    };
  }); };
  config = {
    security.sudo.wheelNeedsPassword = false;
    users.users = mapAttrs (userName: userConfig: {
      isNormalUser = true;
      inherit (userConfig) shell packages;
      description = userConfig.fullName;
      initialPassword = "1234";
    }) cfg;
  };
}
