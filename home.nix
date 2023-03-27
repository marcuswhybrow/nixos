{ config, pkgs, ... }: {
  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      htop
      alacritty
      brave
    ];
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      bars = []; # disable built-in status bar
      menu = "${pkgs.rofi}/bin/rofi -show drun";
      terminal = "alacritty";
      input."*" = {
        repeat_delay = "300";
	xkb_layout = "gb";
	natural_scroll = "enabled";
	tap = "enabled";
      };
    };
  };

  programs = {
    rofi = {
      enable = true;
      font = "Droid Sans Mono 14";
    };
    fish.enable = true;
    starship.enable = true;

    neovim = {
      enable = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-fish
	vim-nix
	gruvbox
      ];
      extraConfig = ''colorscheme gruvbox'';
    };

    git = {
      enable = true;
      userName = "Marcus Whybrow";
      userEmail = "marcus@whybrow.uk";
      extraConfig = {
        init.defaultBranch = "main";
	core.editor = "vim";
      };
      delta.enable = true;
    };
    gh.enable = true;
  };
}
