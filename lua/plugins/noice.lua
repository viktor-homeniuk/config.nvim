-- return {
--   "folke/noice.nvim",
--   event = "VeryLazy",
--   opts = {
--     -- add any options here
--   },
--   dependencies = {
--     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
--     "MunifTanjim/nui.nvim",
--     -- OPTIONAL:
--     --   `nvim-notify` is only needed, if you want to use the notification view.
--     --   If not available, we use `mini` as the fallback
--     "rcarriga/nvim-notify",
--     }
-- }

return {
  "folke/noice.nvim",
  dependencies = {
    "nvim-lua/popup.nvim",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { ':' }
  },
  config = function()
    require("noice").setup({
      presets = { long_message_to_split = true, },
      lsp = {
        progress = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = false,
        },
      },
      views = {
        hover = {
          relative = "cursor",
        },
        documentation = {
          view = "mini"
        },
        mini = {
          border = {
            style = "rounded",
          },
          position = {
            row = -2,
          },
          win_options = {
            winblend = 0,
            winhighlight = {
              Normal = "NoiceCmdlinePopup",
              FloatBorder = "NoiceCmdlinePopupBorder",
            }
          }
        },
        split = {
          win_options = {
            winhighlight = {
              Normal = "BG_HIGHLIGHT"
            },
          }
        }
      },
    })
  end,
}
