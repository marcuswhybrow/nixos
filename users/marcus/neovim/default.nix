{ config, pkgs, lib, ... }: {
  imports = [
    ./telescope.nix
  ];

  config.home-manager.users.marcus = {
    programs.neovim = {
      enable = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-fish
        vim-nix

        # Docs for install Vim/NeoVim packages with Nix
        # https://github.com/NixOS/nixpkgs/blob/b740337fb5b41e893d456e3b6cd5b62b6dad5098/doc/languages-frameworks/vim.section.md

        # https://github.com/projekt0n/github-nvim-theme
        (pkgs.vimUtils.buildVimPluginFrom2Nix rec {
          pname = "github-nvim-theme";
          version = "0.0.7";
          src = pkgs.fetchFromGitHub {
            owner = "projekt0n";
            repo = "github-nvim-theme";
            rev = "refs/tags/v${version}";
            sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
          };
        })

        nvim-surround
      ];

      # https://github.com/nanotee/nvim-lua-guide
      extraLuaConfig = ''
        -- https://vi.stackexchange.com/questions/3/how-can-i-show-relative-line-numbers
        vim.api.nvim_command('set number')
        vim.api.nvim_command('set relativenumber')

        require("github-theme").setup({
          transparent = true,
          theme_style = "light",
          colors = {
            hint = "orange",
            error = "#ff0000"
          }
        })
      '';
    };
  };
}
