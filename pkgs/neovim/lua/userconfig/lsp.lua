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

local lspconfig = require('lspconfig')

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lspconfig.gopls.setup{}

-- https://templ.guide/commands-and-tools/ide-support#neovim--050
lspconfig.templ.setup{}

lspconfig.tailwindcss.setup({
  filetypes = {
    'templ',
    'html',
    'gohtml',
    'go',
  },
  init_options = {
    userLanguages = {
      templ = "html",
      go = "html",
    }
  },
  handlers = {
    -- https://github.com/tailwindlabs/tailwindcss-intellisense/issues/188#issuecomment-886110433
    ["tailwindcss/getConfiguration"] = function (_, _, params, _, bufnr, _)
      -- tailwindcss lang server waits for this repsonse before providing hover
      vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", { _id = params._id })
    end
  },
})

lspconfig.nil_ls.setup{}
lspconfig.bashls.setup{}
lspconfig.html.setup{}
lspconfig.cssls.setup{}
lspconfig.jsonls.setup{}
lspconfig.eslint.setup{}
lspconfig.yamlls.setup{}
lspconfig.marksman.setup{}

lspconfig.rust_analyzer.setup{
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true;
        disabled = {"unresolved-proc-macro"},
        enableExperimental = true,
      },

      cargo = {
        buildScripts = {
          enable = true;
        },
      },

      procMacro = {
        enable = true;
      },
    },
  },
}

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

  mapping = {
    ["<Tab>"] = cmp_action.tab_complete(),
    ["<S-Tab>"] = cmp_action.select_prev_or_fallback(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },

  snippet = {
    expand = function(args)
      local luasnip = require("luasnip")
      if not luasnip then
        return
      end 
      luasnip.lsp_expand(args.body)
    end,
  },

  sources = {
    { name = "path" },
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "nvim_lua" },
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

-- https://templ.guide/commands-and-tools/ide-support#format-on-save-1
vim.api.nvim_create_autocmd(
  {
    "BufWritePre"
  },
  {
    pattern = {"*.templ"},
    callback = function()
      vim.lsp.buf.format()
    end,
  }
)
