local transparent = false
return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = transparent,
      }
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent_background = transparent,
      }
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent_mode = transparent,
      }
    end,
  },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "gruvbox",
  --   },
  -- },
}
