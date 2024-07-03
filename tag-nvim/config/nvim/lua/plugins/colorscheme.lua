local transparent = true
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
    config = function()
      require("catppuccin").setup({
        -- flavour = transparent and "mocha" or "macchiato",
        -- transparent_background = transparent,
        -- styles = {
        --   keywords = { "bold" },
        --   functions = { "italic" },
        -- },
        -- integrations = {
        --   alpha = false,
        --   neogit = false,
        --   nvimtree = false,
        --   illuminate = false,
        --   treesitter_context = false,
        --   rainbow_delimiters = false,
        --   dropbar = { enabled = false },
        --   mason = true,
        --   noice = true,
        --   notify = true,
        --   neotest = true,
        --   which_key = true,
        --   telescope = { style = transparent and nil or "nvchad" },
        -- },
        -- custom_highlights = function(color) end,
      })
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
  --     colorscheme = "catppuccin",
  --   },
  -- },
}
