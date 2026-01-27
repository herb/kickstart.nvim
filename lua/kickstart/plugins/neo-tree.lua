-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '<leader>e', ':Neotree filesystem reveal bottom<CR>', desc = '[E]xplorer (Neo-tree)', silent = true },
  },
  opts = {
    filesystem = {
      bind_to_cwd = false,
      window = {
        mappings = {
          ['<leader>e'] = 'close_window',
          ['\\'] = nil,
        },
      },
      -- Show hidden files by default
      filtered_items = {
        hide_dotfiles = false,
        hide_hidden = false,
      },
      -- :e . opens in current window (legacy netrw behavior)
      hijack_netrw_behavior = 'open_current',
    },
    -- Bottom split for :Neotree reveal
    window = {
      position = 'bottom',
      width = function()
        return math.floor(vim.o.columns * 0.8)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.3)
      end,
    },
    buffers = {
      window = {
        position = 'bottom',
      },
    },
    git_status = {
      window = {
        position = 'bottom',
      },
    },
    diagnostics = {
      window = {
        position = 'bottom',
      },
    },
  },
}
