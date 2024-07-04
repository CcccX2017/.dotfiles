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
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = transparent and "mocha" or "macchiato",
        transparent_background = transparent,
        integrations = {
          aerial = true,
          alpha = true,
          cmp = true,
          dashboard = true,
          flash = true,
          gitsigns = true,
          headlines = true,
          illuminate = true,
          indent_blankline = { enabled = true },
          leap = true,
          lsp_trouble = true,
          mason = true,
          markdown = true,
          mini = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
          navic = { enabled = true, custom_bg = "lualine" },
          neotest = true,
          neotree = true,
          noice = true,
          notify = true,
          semantic_tokens = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          which_key = true,
        },
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
