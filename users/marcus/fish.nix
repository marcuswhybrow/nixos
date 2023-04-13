{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        d = ''cd ~/.dotfiles'';
        c = ''cd ~/.dotfiles && vim users/(whoami)/default.nix'';
        config= ''cd ~/.config'';

        t = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d).md'';
        y = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d --date yesterday).md'';

        osswitch = ''sudo nixos-rebuild switch'';
        ostest = ''sudo nixos-rebuild test'';

        gs = ''git status'';
        ga = ''git add .'';
        gc = ''git commit -m'';
        gp = ''git push'';
        gd = ''git diff'';
      };

      functions = {
        fish_greeting = ''echo "$(whoami) @ $(hostname)"'';
      };

      # The `dbus-run-session` part allows sway to access Windows SMB
      # shares without errors. (https://nixos.wiki/wiki/Samba)
      loginShellInit = ''dbus-run-session sway'';
    };

    programs.starship = {
      enable = true;
      package = pkgs.unstable.starship;
      settings.nix_shell.heuristic = true;
    };
  };
}
