# https://github.com/nvim-telescope/telescope.nvim
{ config, pkgs, lib, ... }: {
  config.home-manager.users.marcus = {
    home.packages = with pkgs; [
      ripgrep # builtin.live_grep requires ripgrep
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
      -- https://github.com/nvim-telescope/telescope.nvim#usage
      local telescopeBuiltin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
      vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
      vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, {})
      -- means: Whilst in normal mode ('n') pressing '\fh' ('<leader>fh') runs help_tags command
    '';
  };
}
