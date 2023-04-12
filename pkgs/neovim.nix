{
  pkgs,
  lib, 
  stdenv, 
  makeBinaryWrapper,

  beforeNeovimOpens ? "",
  afterNeovimCloses ? "",

}: let
  neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (pkgs.neovimUtils.makeNeovimConfig {
    # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/utils.nix#L24
    withPython3 = false; # defaults to true
    extraPython3Packages = _: [ ];
    withNodeJs = false;
    withRuby = false; # defaults to true
    extraLuaPackages = _: [ ];
    customRC = '''';

    plugins = with pkgs.vimPlugins; [
      telescope-fzf-native-nvim
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      (nvim-treesitter.withPlugins (p: with p; [
        nix
        go
        rust
        bash
        fish
      ]))
      nvim-lspconfig
      (pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "lsp-zero-nvim";
        version = "2.x";
        src = pkgs.fetchFromGitHub {
          owner = "VonHeikemen";
          repo = "lsp-zero.nvim";
          rev = "eb278c30b6c50e99fdfde52f7da0e0ff8d17c07e";
          sha256 = "sha256-C2LvhoNdNXRyG+COqVZv/BcUh6y82tajXipsqdySJJQ=";
        };
      })
      vim-nix
      lualine-nvim
    ];

    # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/wrapper.nix#L13
    extraName = "";
    withPython2 = false;
    vimAlias = true; # defaults to false
    viAlias = false;
    wrapRc = false;
    neovimRcContent = "";
  });

  luaInit = pkgs.writeText "init.lua" ''
    do
      -- Line numbers
      vim.api.nvim_command('set number')
      vim.api.nvim_command('set relativenumber')
    end

    do
      -- Keymaps
      vim.g.mapleader = " "
      vim.keymap.set("n", "<Leader>e", vim.cmd.Ex)

      -- toggle status line
      vim.keymap.set('n', '<Leader>s', function()
        if vim.api.nvim_get_option('laststatus') == 0 then
          vim.api.nvim_set_option('laststatus', 2)
        else
          vim.api.nvim_set_option('laststatus', 0)
        end
      end)
    end

    do
      -- Telescope
      -- https://github.com/nvim-telescope/telescope.nvim#usage
      local telescopeBuiltin = require('telescope.builtin')

      vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
      vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
      vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, {})
    end

    do
      -- Treesitter
      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,
        },
      }
    end

    do 
      -- LSP
      local lsp = require('lsp-zero').preset({})
      local lspconfig = require('lspconfig')

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      lsp.setup_servers({
        'gopls',
        'nil_ls',
      })

      lsp.setup()
    end

    do
      -- Lualine

      -- https://neovim.io/doc/user/options.html#'showtabline'
      vim.api.nvim_set_option('showtabline', 0)

      local colors = {
        blue   = '#80a0ff',
        cyan   = '#79dac8',
        black  = '#000000',
        white  = '#ffffff',
        red    = '#ff5189',
        violet = '#d183e8',
        grey   = '#cccccc',
      }

      require('lualine').setup({
        options = {
          globalstatus = false,
          theme = {
            normal = {
              a = { fg = colors.black, bg = 'NONE' },
              b = { fg = colors.black, bg = 'NONE' },
              c = { fg = colors.black, bg = 'NONE' },
              x = { fg = colors.black, bg = 'NONE' },
              y = { fg = colors.black, bg = 'NONE' },
              z = { fg = colors.black, bg = 'NONE' },
            },

            insert = { a = { fg = colors.black, bg = colors.blue } },
            visual = { a = { fg = colors.black, bg = colors.cyan } },
            replace = { a = { fg = colors.black, bg = colors.red } },

            inactive = {
              a = { fg = colors.black, bg = 'NONE' },
              b = { fg = colors.black, bg = 'NONE' },
              c = { fg = colors.black, bg = 'NONE' },
              x = { fg = colors.black, bg = 'NONE' },
              y = { fg = colors.black, bg = 'NONE' },
              z = { fg = colors.black, bg = 'NONE' },
            },
          },
          component_separators = ''',
          section_separators = ''',
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {
            'mode',
            'filename',
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 'filename' },
        },
        extensions = {},
      })
    end

  '';

  pathPkgs = with pkgs; [
    nil
    gopls
  ];

  wrapperScript = pkgs.writeShellScript "vim" ''
    ${beforeNeovimOpens}
    ${neovim}/bin/nvim -u ${luaInit} "$@"
    ${afterNeovimCloses}
  '';
in stdenv.mkDerivation {
  pname = "neovim";
  version = "unstable";
  src = ./.;

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    makeWrapper ${wrapperScript} $out/bin/vim \
      --suffix PATH : ${lib.makeBinPath pathPkgs}
  '';
}
