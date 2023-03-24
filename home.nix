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
      menu = "${pkgs.rofi}/bin/rofi -show drun";
      terminal = "alacritty";
      input."*" = {
        repeat_delay = "300";
	xkb_layout = "gb";
	natural_scroll = "enabled";
	tap = "enabled";
      };
      keycodebindings = {
      	"67" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute";
      	"68" = "exec ${pkgs.pamixer}/bin/pamixer --decrease 5";
      	"69" = "exec ${pkgs.pamixer}/bin/pamixer --increase 5";
      	"232" = "exec ${pkgs.light} -U 10";
      	"233" = "exec ${pkgs.light} -A 10";
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
