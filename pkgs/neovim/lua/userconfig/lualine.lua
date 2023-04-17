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
    component_separators = '',
    section_separators = '',
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
