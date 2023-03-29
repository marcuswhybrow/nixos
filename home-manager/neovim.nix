{ config, lib, pkgs, ... }: let
  inherit (lib) mkIf mkEnableOption;
  inherit (import ../utils { inherit lib; }) options forEachUser;
in {
  options.custom.users = options.mkForEachUser {
    neovim = {
      enable = mkEnableOption "Enable Neovim";
    };
  };

  config = {
    home-manager.users = forEachUser config (user: {
      home.packages = with pkgs; [
        # Wayland system clipboard support for copy ("+y) and paste ("+p)
        wl-clipboard
      ];
      programs.neovim = mkIf user.neovim.enable {
        enable = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          vim-fish
          vim-nix
        ];
      };
    });
  };
}
