{ config , lib, pkgs, ... }: let
  inherit (lib) mkOption types;
  inherit (builtins) mapAttrs foldl';
  inherit (import ./utils { inherit lib; }) options forEachUser merge;
in {
  options.custom.users = options.mkForEachUser {
    fullName = mkOption { type = types.str; };
    groups = mkOption { type = with types; listOf str; };
    shell = mkOption { type = types.package; };
    packages = mkOption { type = with types; listOf package; };
    extraConfig = options.mkAttrs {};
    extraHomeManagerConfig = options.mkAttrs {}; 
  };
  config = {
    security.sudo.wheelNeedsPassword = false;
    users.users = forEachUser config (
      user: merge [
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
      users =  forEachUser config (
        user: merge [
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
