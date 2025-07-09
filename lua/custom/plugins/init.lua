-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '┊',
      },
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = 'iceberg_dark',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = { { 'filename', path = 1 } },
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1 } },
        },
      }
    end,
  },
}
