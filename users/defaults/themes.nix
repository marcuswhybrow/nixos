[
  ({ config, lib, pkgs, helpers, ... }: {
    options.custom.users = helpers.options.mkForEachUser {
      theme = helpers.options.mkEnum "light" [ "light" ];
    };

    # Theme's only responsible for colors and fonts, not layout.
    config.home-manager.users = helpers.config.mkForEachUser config (user: let
      theme = ./themes/${user.theme}.nix;
    in (
      import theme { inherit user config lib pkgs helpers; }
    ));
  })
]
