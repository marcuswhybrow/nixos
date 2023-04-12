{ pkgs, ... }: {
  imports = [
    ./sway.nix
    ./waybar.nix
    ./fish.nix
    ./alacritty.nix
    ./git.nix
  ];

  config.users.users.marcus = let
    terminalPadding = 20;
  in {
    description = "Marcus Whybrow";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    packages = let 
      marcus.alacritty = pkgs.custom.alacritty.override {
        padding = terminalPadding;
        opacity = 0.95;
      };
      marcus.neovim = pkgs.custom.neovim.override {
        beforeNeovimOpens = ''
          ${marcus.alacritty}/bin/alacritty msg config \
            window.padding.x=0 \
            window.padding.y=0
          ${pkgs.wtype}/bin/wtype -M ctrl 0
        '';
        afterNeovimCloses = ''
          ${marcus.alacritty}/bin/alacritty msg config \
            window.padding.x=${toString terminalPadding} \
            window.padding.y=${toString terminalPadding}
          ${pkgs.wtype}/bin/wtype -M ctrl 0
        '';
      };
    in with pkgs; [
      # htop requires lsof when you press `l` on a process
      htop lsof

      brave
      vimb
      discord
      obsidian

      plex-media-player

      ranger

      marcus.alacritty
      marcus.neovim
      custom.private
    ];
  };

  config.home-manager.users.marcus = let
    primaryColor = "#1e88eb";
  in {

    # Composition

    programs.waybar.marcusBar.colors.primary = primaryColor;
    programs.git.delta.options.light = true;

    programs.rofi = {
      lightTheme = true;
      border.color = primaryColor;
    };

    services.dunst = {
      lightTheme = true;
      frame.color = primaryColor;  # border
      foreground = primaryColor;   # text
      highlight = primaryColor;    # progress bar
      progressBar.height = 30;
    };
  };
}
