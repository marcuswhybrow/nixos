vim.g.mapleader = " "

-- File browser
vim.keymap.set("n", "<Leader>e", vim.cmd.Ex, { desc = '[E]xplore files in current directory' })

-- toggle status line
vim.keymap.set('n', '<Leader>s', function()
  if vim.api.nvim_get_option('laststatus') == 0 then
    vim.api.nvim_set_option('laststatus', 2)
  else
    vim.api.nvim_set_option('laststatus', 0)
  end
end, { desc = '[S]how status line' })

-- Move visual blocks up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move visual block down one line' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move visual block up one line' })

-- Conflate lines
vim.keymap.set("n", "J", "mzJ`z", { desc = '[J]oin this line with the next line' })
-- Page up/down also centers screen 
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Go [D]own and center the screen' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Go [U]p and center the screen' })
-- Next/prev search also centers screen
vim.keymap.set("n", "n", "nzzzv", { desc = 'Goto [N]ext search result and center the screen' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Goto previous search result and center the screen' })

-- Paste over selection
vim.keymap.set("x", "<leader>p", "\"_dP", { desc = '[P]aste over selection' })

-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y", { desc = '[Y]ank to system clipboard' })
vim.keymap.set("v", "<leader>y", "\"+y", { desc = '[Y]ank to system clipboard' })
vim.keymap.set("n", "<leader>Y", "\"+Y", { desc = '[Y]ank to system clipboard' })

-- Delete to void register
vim.keymap.set("n", "<leader>d", "\"_d", { desc = '[D]elete to void register' })
vim.keymap.set("v", "<leader>d", "\"_d", { desc = '[D]elete to void register' })

-- Unmap Q
vim.keymap.set("n", "Q", "<nop>", { desc = 'Disable [Q] as it\'s too dangerous' })

--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- https://neovim.io/doc/user/quickfix.html
--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
--vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
--vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Scripting
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = 'Enable e[X]ecute bit on current file' })

-- Fugitive
vim.keymap.set("n", "<leader>gs", ":Git<cr>", { desc = '[G]it [S]how' })
vim.keymap.set("n", "<leader>gp", ":Git push<cr>", { desc = '[G]it [P]ush' })

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = 'Open [U]ndo tree' })

-- Harpoon
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")
vim.keymap.set("n", "<leader>a", harpoon_mark.add_file, { desc = '[A]dd file to Harpoon' })
vim.keymap.set("n", "<C-e>", harpoon_ui.toggle_quick_menu, { desc = '[E]nter Harpoon' }) 
vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end, { desc = 'Open first path in Harpoon' }) 
vim.keymap.set("n", "<C-j>", function() harpoon_ui.nav_file(2) end, { desc = 'Open seond path in Harpoon' }) 
vim.keymap.set("n", "<C-k>", function() harpoon_ui.nav_file(3) end, { desc = 'Open third path in Harpoon' }) 
vim.keymap.set("n", "<C-l>", function() harpoon_ui.nav_file(4) end, { desc = 'Open forth path in Harpoon' }) 

-- See `:help telescope`
local telescopeBuiltin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, { desc = '[F]ind using [G]rep' })
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, { desc = '[F]ind within all [B]uffers' })
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, { desc = '[F]ind within [H]elp tags' })
vim.keymap.set('n', '<leader>fk', telescopeBuiltin.keymaps, { desc = '[F]ind [K]eymaps' })

