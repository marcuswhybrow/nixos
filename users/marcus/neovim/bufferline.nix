# https://github.com/akinsho/bufferline.nvim#usage
{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    home.packages = with pkgs; [
    ];

    programs.neovim.plugins = with pkgs.vimPlugins; [
      bufferline-nvim
    ];

    programs.neovim.extraLuaConfig = ''
      -- https://github.com/akinsho/bufferline.nvim
      vim.opt.termguicolors = true;
      require("bufferline").setup{}
    '';
  };
}
