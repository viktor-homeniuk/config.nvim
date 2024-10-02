-- Minor plugins with no/minimal configuration
return {
  -- theme
  { "ntk148v/habamax.nvim",  dependencies = { "rktjmp/lush.nvim" } },

  -- -- Git related plugins
  -- 'tpope/vim-fugitive',
  -- 'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  { 'numToStr/Comment.nvim', opts = {} },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- -- Set lualine as statusline
  -- {
  --   'nvim-lualine/lualine.nvim',
  --   opts = {
  --     options = {
  --       icons_enabled = false,
  --       theme = 'onedark',
  --       component_separators = '|',
  --       section_separators = '',
  --     },
  --   },
  -- },
  --
  -- {"github/copilot.vim"}

}
