{ config, lib, pkgs, ... }: {
  imports = [
    ./sway.nix
    ./waybar.nix
    ./fish.nix
    ./alacritty.nix
    ./neovim
    ./git.nix
  ];

  config.users.users.marcus = {
    description = "Marcus Whybrow";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  config.home-manager.users.marcus = let
    primaryColor = "#1e88eb";
  in {

    home.packages = with pkgs; [
      # htop requires lsof when you press `l` on a process
      htop lsof

      brave
      vimb
      discord
      obsidian

      plex-media-player

      ranger
    ];


    # Composition

    programs.waybar.marcusBar.colors.primary = primaryColor;
    programs.alacritty.lightTheme = true;
    programs.alacritty.settings.window.opacity = 0.95;
    programs.rofi.lightTheme = true;
    programs.git.delta.options.light = true;

    services.dunst.lightTheme = true;
    services.dunst.frame.color = primaryColor;
    services.dunst.foreground = primaryColor;
  };
}
