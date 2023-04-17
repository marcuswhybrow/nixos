vim.g.mapleader = " "

-- File browser
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

-- Scripting
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Fugitive
vim.keymap.set("n", "<leader>g", vim.cmd.Git)

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu) 
vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end) 
vim.keymap.set("n", "<C-j>", function() ui.nav_file(2) end) 
vim.keymap.set("n", "<C-k>", function() ui.nav_file(3) end) 
vim.keymap.set("n", "<C-l>", function() ui.nav_file(4) end) 

-- Telescope
-- https://github.com/nvim-telescope/telescope.nvim#usage
local telescopeBuiltin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, {})
