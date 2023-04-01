[
  ({ pkgs, ... }: {
    users.users.anne = {
      description = "Anne Whybrow";
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "video" ];
      shell = pkgs.fish;
    };

    custom.users.anne = {
      theme = "light";
      audio.volume.step = 5;
      display.brightness.step = 5;
    };

    home-manager.users.anne = {
      home.packages = with pkgs; [
        brave
        cage
      ];

      programs.fish.enable = true;

      # Runs when fish starts
      xdg.configFile."fish/config.fish" = {
        executable = true;
        text = ''
          if status is-interactive
            cage brave
          end
        '';
      };
    };
  })
]
