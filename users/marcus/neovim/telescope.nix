# https://github.com/nvim-telescope/telescope.nvim
{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    home.packages = with pkgs; [
      ripgrep
      fd
    ];

    programs.neovim.plugins = with pkgs.vimPlugins; [
      telescope-nvim
      telescope-fzf-native-nvim
      nvim-web-devicons
      plenary-nvim
      nvim-treesitter
    ];

    programs.neovim.extraLuaConfig = ''

    '';
  };
}
