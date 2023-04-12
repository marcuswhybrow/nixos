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
      (pkgs.vimUtils.buildVimPluginFrom2Nix rec {
        pname = "github-nvim-theme";
        version = "0.0.7";
        src = pkgs.fetchFromGitHub {
          owner = "projekt0n";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
        };
      })
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
      vim.api.nvim_command('set cmdheight=1')

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
      -- color theme
      require("github-theme").setup({
        transparent = true,
        hide_inactive_statusline = false,
      })
      vim.cmd('colorscheme github_light')
    end

    do
      -- Lualine

      -- https://neovim.io/doc/user/options.html#'showtabline'
      vim.api.nvim_set_option('showtabline', 0)
      vim.api.nvim_command(':hi! link StatusLine lualine_z_inactive')
      vim.api.nvim_command(':hi! link StatusLineNC lualine_z_inactive')
      vim.api.nvim_command(':hi! link SignColumn Normal')


      local filename = {
        'filename',
        file_status = true,
        newfile_status = true,
        path = 1,
        shorting_target = 40,
        symbols = {
          modified = '[+]',
          readonly = '[-]',
          unnamed = '[No Name]',
          newfile = '[New]',
        },
        padding = { left = 1, right = 0 },
      }

      local filetype = {
        'filetype',
        colored = false,
        icon_only = true,
        padding = { left = 1, right = 1 },
      }

      local diff = {
        'diff',
        colored = false,
        diff_color = {
          added    = 'DiffAdd',
          modified = 'DiffChange',
          removed  = 'DiffDelete',
        },
        symbols = {
          added = '+',
          modified = '~',
          removed = '-'
        },
      }

      local branch = {
        'branch',
        icon = { '', align='right' },
        padding = { left = 1, right = 0 },
      }

      local diagnostics = {
        sources = { 'nvim_lsp', 'nvim_diagnostic' },
        sections = { 'error', 'warn', 'info', 'hint' },

        diagnostics_color = {
          error = 'DiagnosticError',
          warn  = 'DiagnosticWarn',
          info  = 'DiagnosticInfo',
          hint  = 'DiagnosticHint',
        },
        symbols = {
          error = 'E',
          warn = 'W',
          info = 'I',
          hint = 'H'
        },
        colored = true,
        update_in_insert = false,
        always_visible = true,
      }

      local location = {
        'location',
        padding = { left = 0, right = 1 },
      }

      local progress = {
        'progress',
        padding = { left = 1, right = 0 },
      }

      local active = { bg = '#eaeaed', fg = '#000000' }
      local inactive = { bg = '#eeeeee', fg = '#000000' }
      local insert = { fg = '#000000', bg = '#80a0ff' }
      local visual = { fg = '#000000', bg = '#79dac8' }
      local replace = { fg = '#000000', bg = '#ff5189' }
      local command = { fg = '#000000', bg = '#d183e8' }

      vim.api.nvim_set_hl(0, "StatusLine", { bg = '#dddddd' })
      vim.api.nvim_command('hi SignColumn ctermbg=none')

      local allParts = function(s)
        return { a = s, b = s, c = s, x = s, y = s, z = s }
      end

      require('lualine').setup({
        options = {
          globalstatus = true,
          component_separators = ''',
          section_separators = ''',
          always_divide_middle = true,

          theme = {
            normal = {
              a = active,
              b = active,
              c = active,
              x = active,
              y = active,
              z = active,
            },

            insert = allParts(insert),
            visual = allParts(visual),
            replace = allParts(replace),

            inactive = {
              a = inactive,
              b = inactive,
              c = inactive,
              x = inactive,
              y = inactive,
              z = inactive,
            },
          },
        },

        --[[
        winbar = {
          lualine_a = { filename },
          lualine_b = {},
        },

        winbar_inactive = {
          lualine_a = { filename },
          lualine_b = {},
        },
        --]]

        sections = {
          lualine_a = {
            filename,
          },
          lualine_b = {
            filetype,
            branch,
            diff,
          },
          lualine_c = {
            diagnostics,
          },
          lualine_x = {},
          lualine_y = {
            progress,
            location,
          },
          lualine_z = {
            'mode',
          },
        },

        inactive_sections = {
          lualine_a = { filename },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },

        extensions = {},
      })
    end

    do
      -- colors
      vim.api.nvim_set_hl(0, 'SignColumn', { fg = 'black', bg = 'NONE' })
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
