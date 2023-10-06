{
  pkgs,

}: pkgs.callPackage ../../pkgs/fish.nix {
  init = let
    obsidian = "~/obsidian/Personal";
  in ''
    if status is-login
      if [ (hostname) = "marcus-laptop" ]
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.marcus.sway}/bin/sway
      end
    end

    if status is-interactive
      abbr --add n "tmux new -A -s nixos -c ~/.nixos"
      abbr --add c "tmux new -A -s config -c ~/.config"
      abbr --add r work_on_repository

      abbr --add t vim ${obsidian}/Timeline/$(date +%Y-%m-%d).md
      abbr --add y vim ${obsidian}/Timeline/$(date +%Y-%m-%d --date yesterday).md

      abbr --add osswitch sudo nixos-rebuild switch
      abbr --add ostest sudo nixos-rebuild test

      abbr --add gs git status
      abbr --add ga git add .
      abbr --add gc git commit
      abbr --add gp git push
      abbr --add gd git diff

      ${pkgs.marcus.starship}/bin/starship init fish | source
      ${pkgs.direnv}/bin/direnv hook fish | source
    end
  '';

  functions = {
    fish_greeting = ''echo (whoami) @ (hostname)'';
    work_on_repository = ''
      set name (ls $HOME/Repositories | fzf --bind tab:up,btab:down)
      tmux new \
        -A \
        -s $name \
        -c $HOME/Repositories/$name
    '';
  };
}
