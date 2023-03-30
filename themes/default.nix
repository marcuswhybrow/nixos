{ config, lib, pkgs, ... }: let
  utils = import ../utils { inherit lib; };
  theme = ./${config.custom.theme}.nix;
in {
  options.custom.users = utils.options.mkForEachUser {
    theme = utils.options.mkEnum "light" [ "light" ];
  };

  # Theme's only responsible for colors and fonts, not layout.
  config.home-manager.users = utils.config.mkForEachUser config (user: let
    theme = ./${user.theme}.nix;
  in (
    import theme { inherit user config lib pkgs; }
  ));
}

  
