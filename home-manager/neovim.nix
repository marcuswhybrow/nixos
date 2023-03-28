{ config, lib, pkgs, ... }: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  inherit (builtins) mapAttrs;
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
        ];
        extraConfig = ''colorscheme catppuccin-latte'';
      };
    }) config.custom.users;
  };
}
