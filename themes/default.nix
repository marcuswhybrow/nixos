{ config, lib, pkgs, ... }: let
  inherit (import ../utils { inherit lib; }) options forEachUser;
  theme = ./${config.custom.theme}.nix;
in {
  options.custom.users = options.mkForEachUser {
    theme = options.mkEnum "light" [
      "light"
    ];
  };

  # Theme's only responsible for colors and fonts, not layout.
  config.home-manager.users = forEachUser config (user: let
    theme = ./${user.theme}.nix;
  in (
    import theme { inherit user config lib pkgs; }
  ));
}

  
