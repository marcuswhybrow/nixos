{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  inherit (import ../utils { inherit lib; }) forEachUser;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.git = {
      enable = mkEnableOption "Enable git tool chain";
      userName = mkOption { type = types.str; };
      userEmail = mkOption { type = types.str; };
    };
  }); };

  config = {
    home-manager.users = forEachUser config (user: {
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
