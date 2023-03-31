outputs: pkgs: {
  theme = "light";
  fullName = "Anne Whybrow";
  groups = [ "networkmanager" "video" ];
  shell = pkgs.fish;

  packages = with pkgs; [
    brave
    cage
  ];

  audio.volume.step = 5;
  display.brightness.step = 5;

  extraHomeManagerConfig = {
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
}

