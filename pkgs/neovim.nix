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
      harpoon
      undotree
      vim-fugitive
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-cmdline-history
      nvim-cmp
      cmp-git
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
    end

    do
      -- Settings
      vim.opt.nu = true
      vim.opt.relativenumber = true

      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

      vim.opt.smartindent = true

      vim.opt.wrap = false

      -- Long term undos
      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
      vim.opt.undofile = true

      vim.opt.hlsearch = false
      vim.opt.incsearch = true

      vim.opt.termguicolors = true

      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
      vim.opt.isfname:append("@-@")

      vim.opt.updatetime = 50

      vim.opt.colorcolumn = "80"
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

      -- Move visual blocks up and down
      vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
      vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

      -- Conflate lines
      vim.keymap.set("n", "J", "mzJ`z")
      -- Page up/down also centers screen 
      vim.keymap.set("n", "<C-d>", "<C-d>zz")
      vim.keymap.set("n", "<C-u>", "<C-u>zz")
      -- Next/prev search also centers screen
      vim.keymap.set("n", "n", "nzzzv")
      vim.keymap.set("n", "N", "Nzzzv")

      -- Paste over selection
      vim.keymap.set("x", "<leader>p", "\"_dP")
      
      -- Yank to system clipboard
      vim.keymap.set("n", "<leader>y", "\"+y")
      vim.keymap.set("v", "<leader>y", "\"+y")
      vim.keymap.set("n", "<leader>Y", "\"+Y")

      -- Delete to void register
      vim.keymap.set("n", "<leader>d", "\"_d")
      vim.keymap.set("v", "<leader>d", "\"_d")

      -- Unmap Q
      vim.keymap.set("n", "Q", "<nop>")

      --vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

      -- https://neovim.io/doc/user/quickfix.html
      --vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
      --vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
      --vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
      --vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

      vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
    end

    do
      -- Fugitive
      vim.keymap.set("n", "<leader>g", vim.cmd.Git)
    end

    do
      -- Undotree
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end

    do
      -- Harpoon
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>a", mark.add_file)
      vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu) 
      vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end) 
      vim.keymap.set("n", "<C-j>", function() ui.nav_file(2) end) 
      vim.keymap.set("n", "<C-k>", function() ui.nav_file(3) end) 
      vim.keymap.set("n", "<C-l>", function() ui.nav_file(4) end) 
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
      -- LSP & CMP
      local lsp = require('lsp-zero').preset({
        -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp
        manage_nvim_cmp = {
          set_sources = "recommended",
          set_basic_mappings = true,
          set_extra_mappins = false, 
          use_luasnip = false,
          set_format = true,
          documentation_window = true,
        }
      })

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({ buffer = bufnr })
        lsp.buffer_autoformat()
        vim.keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<cr>", { buffer = true })
      end)

      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      require'lspconfig'.gopls.setup{}
      require'lspconfig'.nil_ls.setup{}
      require'lspconfig'.bashls.setup{}
      require'lspconfig'.rust_analyzer.setup{}
      require'lspconfig'.html.setup{}
      require'lspconfig'.cssls.setup{}
      require'lspconfig'.jsonls.setup{}
      require'lspconfig'.eslint.setup{}
      require'lspconfig'.yamlls.setup{}
      require'lspconfig'.marksman.setup{}

      -- Manual formatting (instead of buffer_autoformat() above)
      --[[
      lsp.format_on_save({
        servers = {
          ["lua_ls"] = {"lua"},
        }
      })
      --]]

      lsp.set_sign_icons({
        error = '✘',
        warn = '▲',
        hint = '⚑',
        info = '»',
      })

      lsp.setup()

      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()

      cmp.setup({
        preselect = "item",

        completion = {
          completeopt = "menu,menuone,noinsert",
        },

        sources = {
          { name = "path" },
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "nvim_lua" },
        },

        mapping = {
          ["<Tab>"] = cmp_action.tab_complete(),
          ["<S-Tab>"] = cmp_action.select_prev_or_fallback(),

          --[[
          ["J"] = cmp_action.tab_complete(),
          ["K"] = cmp_action.select_prev_or_fallback(),
          ["L"] = cmp.mapping.confirm({ select = false }),
          --]]

          ["<Down>"] = cmp_action.tab_complete(),
          ["<Up>"] = cmp_action.select_prev_or_fallback(),
          ["<Right>"] = cmp.mapping.confirm({ select = false }),


          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        },
      })

      cmp.setup.filetype("gitcommit", {
        source = cmp.config.sources({
          { name = "cmp_git" },
        }, {
          { name = "buffer" },
        })
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        })
      })
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
          globalstatus = false,
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
    nodePackages.bash-language-server
    nodePackages.vscode-langservers-extracted # html css json eslint
    nodePackages.yaml-language-server
    rust-analyzer
    marksman # markdown
    # https://github.com/hangyav/textLSP has no package
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
