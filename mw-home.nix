{ pkgs, lib, config, ... }:

let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.mwHome;
in {
  options.mwHome.enable = mkEnableOption "Home Manager setup";

  config = mkIf cfg.enable {
    home-manager.users.marcus = { pkgs, ... }: {

      home = {
        stateVersion = config.system.stateVersion;
        packages = with pkgs; [
          htop
          alacritty
          brave
        ];
      };

      wayland.windowManager.sway = {
        enable = true;
        config = {
          bars = [];   # disable Sway bar
          menu = "${pkgs.rofi}/bin/rofi -show drun";
          terminal = "alacritty";
          input."*" = {
            repeat_delay = "300";
            xkb_layout = "gb";
            natural_scroll = "enabled";
            tap = "enabled";
          };
          keycodebindings = {
            # Volume
            "67" = "exec pamixer --toggle-mute";   # fn+F1
            "68" = "exec pamixer --decrease 5";    # fn+F2
            "69" = "exec pamixer --increase 5";    # fn+F3

            # Screen brightness
            "232" = "exec light -U 10";   # fn+F8 (decrease)
            "233" = "exec light -A 10";   # fn+F9 (increase)
          };
        };
      };

      programs = {

        rofi = {
          enable = true;
          font = "Droid Sans Mono 14";
        };

        fish = import ./fish;

        starship.enable = true;

        neovim = {
          enable = true;
          vimAlias = true;
          plugins = with pkgs.vimPlugins; [
            vim-fish
            vim-nix
            gruvbox
          ];
          extraConfig = ''
            colorscheme gruvbox
          '';
        };

        git = {
          enable = true;
          userName = "Marcus Whybrow";
          userEmail = "marcus@whybrow.uk";
          extraConfig.init.defaultBranch = "main";
        };

        gh.enable = true;

      };

    };
  };
}
