{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.git = {
      enable = mkEnableOption "Enable git tool chain";
      userName = mkOption { type = types.str; };
      userEmail = mkOption { type = types.str; };
    };
  }); };

  config = {
    home-manager.users = mapAttrs (userName: userConfig: {
      programs = mkIf userConfig.git.enable {
        gh.enable = true;
        git = {
          enable = true;
          inherit (userConfig.git) userName userEmail;
          extraConfig = {
            init.defaultBranch = "main";
            core.editor = "vim";
          };
          delta.enable = true;
        };
      };
    }) config.custom.users;
  };
}
