{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  utils = import ../utils { inherit lib; };
in {
  options.custom.users = utils.options.mkForEachUser {
    git = {
      enable = mkEnableOption "Enable git tool chain";
      userName = mkOption { type = types.str; };
      userEmail = mkOption { type = types.str; };
    };
  };

  config = {
    home-manager.users = utils.config.mkForEachUser config (user: {
      programs = mkIf user.git.enable {
        gh.enable = true;
        git = {
          enable = true;
          inherit (user.git) userName userEmail;
          extraConfig = {
            init.defaultBranch = "main";
            core.editor = "vim";
          };
          delta.enable = true;
        };
      };
    });
  };
}
