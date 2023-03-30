{ config , lib, pkgs, ... }: let
  inherit (lib) mkOption types;
  inherit (builtins) mapAttrs foldl';
  utils = import ./utils { inherit lib; };
in {
  options.custom.users = utils.options.mkForEachUser {
    fullName = mkOption { type = types.str; };
    groups = mkOption { type = with types; listOf str; };
    shell = mkOption { type = types.package; };
    packages = mkOption { type = with types; listOf package; };
    extraConfig = utils.options.mkAttrs {};
    extraHomeManagerConfig = utils.options.mkAttrs {}; 
  };
  config = {
    security.sudo.wheelNeedsPassword = false;
    users.users = utils.config.mkForEachUser config (
      user: utils.merge [
        {
          isNormalUser = true;
          extraGroups = user.groups;
          inherit (user) shell;
          description = user.fullName;
          initialPassword = "1234";
        }
        user.extraConfig
      ]
    );
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users = utils.config.mkForEachUser config (
        user: utils.merge [
          {
            home.stateVersion = config.system.stateVersion; 
            home.packages = user.packages;
          }
          user.extraHomeManagerConfig
        ]
      );
      extraSpecialArgs = { inherit pkgs; };
    };
  };
}
