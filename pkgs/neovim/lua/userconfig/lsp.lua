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
