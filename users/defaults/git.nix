[
  ({ config, lib, pkgs, helpers, ... }: {
    options.custom.users = helpers.options.mkForEachUser {
      git.enable = lib.mkEnableOption "Enable git tool chain";
      git.userName = lib.mkOption { type = lib.types.str; };
      git.userEmail = lib.mkOption { type = lib.types.str; };
    };

    config.home-manager.users = helpers.config.mkForEachUser config (user: {
      programs = lib.mkIf user.git.enable {
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
  })
]
