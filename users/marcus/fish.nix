{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    programs.fish = {
      enable = true;
      shellAbbrs = let
        nixos = "~/.nixos";
        config = "~/.config";
        obsidian = "~/obsidian/Personal";
      in {
        d = ''cd ${nixos}'';
        c = ''cd ${nixos} && vim users/(whoami)/default.nix'';
        config= ''cd ${config}'';

        t = ''vim ${obsidian}/Timeline/(date +%Y-%m-%d).md'';
        y = ''vim ${obsidian}/Timeline/(date +%Y-%m-%d --date yesterday).md'';

        osswitch = ''sudo nixos-rebuild switch'';
        ostest = ''sudo nixos-rebuild test'';

        gs = ''git status'';
        ga = ''git add .'';
        gc = ''git commit'';
        gp = ''git push'';
        gd = ''git diff'';
      };

      functions = {
        fish_greeting = ''echo "$(whoami) @ $(hostname)"'';
      };

      # The `dbus-run-session` part allows sway to access Windows SMB
      # shares without errors. (https://nixos.wiki/wiki/Samba)
      loginShellInit = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.marcus.sway}/bin/sway
      '';
    };

    programs.starship = {
      enable = true;
      package = pkgs.unstable.starship;
      settings.nix_shell.heuristic = true;
    };
  };
}
