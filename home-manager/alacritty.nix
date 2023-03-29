{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  inherit (import ../utils { inherit lib; }) forEachUser;
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.alacritty = {
      enable = mkEnableOption "Enable alacritty";
    };
  }); };

  config = {
    home-manager.users = forEachUser config (user: {
      programs.alacritty = {
        enable = user.alacritty.enable;
        settings = {
          window.padding = { x = 5; y = 5; };
        };
      };
    });
  };
}
