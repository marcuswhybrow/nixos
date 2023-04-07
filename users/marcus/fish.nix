{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    programs.fish = {
      enable = true;
      shellAbbrs = {
        c = ''vim ~/.dotfiles/systems/(hostname).nix'';
        d = ''cd ~/.dotfiles'';
        config= ''cd ~/.config'';

        t = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d).md'';
        y = ''vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d --date yesterday).md'';

        osswitch = ''sudo nixos-rebuild switch'';
        ostest = ''sudo nixos-rebuild test'';

        gs = ''git status'';
        ga = ''git add .'';
        gc = ''git commit -am'';
        gp = ''git push'';
      };
      functions = {
        fish_greeting = "";
        timeline = ''
          set days (if set --query $argv[1]; echo $argv[1]; else; echo 0; end)
          vim ~/obsidian/Personal/Timeline/(date +%Y-%m-%d --date "$days days ago").md
        '';
      };
      loginShellInit = ''sway'';
    };

    programs.starship.enable = true;
  };
}
