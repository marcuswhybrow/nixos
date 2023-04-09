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
        gc = ''git commit -am'';
        gp = ''git push'';
        gd = ''git diff'';
      };

      functions = {
        fish_greeting = "";
      };
      loginShellInit = ''sway'';
    };

    programs.starship = {
      enable = true;
      package = pkgs.unstable.starship;
      settings.nix_shell.heuristic = true;
    };
  };
}
