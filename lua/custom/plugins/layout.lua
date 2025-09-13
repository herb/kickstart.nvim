return {
  {
    dir = '~/.config/nvim/plugins/layout92',
    name = 'layout92',
    lazy = false, -- run on startup so layout happens right away
    config = function()
      require('layout92').setup {
        -- override defaults here if you want:
        -- target_width = 92,
        -- max         = 5,
        -- alt         = 4,
        -- hidden_width= 1,
        -- sep_cost    = 1,
        -- min_visible = 1,
      }

      -- optional convenience mapping
      vim.keymap.set('n', '<leader>l9', '<cmd>Layout92<cr>', { desc = 'Re-layout 92-col panes' })
    end,
  },
}
