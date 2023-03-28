{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
  github-nvim-theme = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "github-nvim-theme";
    version = "0.0.7";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "refs/tags/v${version}";
      sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
    };
  };
in {
  options.custom.users = mkOption { type = with types; attrsOf (submodule {
    options.neovim = {
      enable = mkEnableOption "Enable Neovim";
    };
  }); };

  config = {
    home-manager.users = mapAttrs (userName: userConfig: {
      home.packages = with pkgs; [

        # Wayland system clipboard support for copy ("+y) and paste ("+p)
        wl-clipboard
      ];
      programs.neovim = mkIf userConfig.neovim.enable {
        enable = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          vim-fish
          vim-nix
          gruvbox
          catppuccin-nvim # https://github.com/catppuccin/nvim
          github-nvim-theme
        ];
        extraConfig = ''colorscheme github_light'';
      };
    }) config.custom.users;
  };
}
