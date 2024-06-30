return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.presets.lsp_doc_border = true
    end,
    dependencies = {
      { "MunifTanjim/nui.nvim", lazy = false },
    },
  },
  -- dashboard
  {
    "nvimdev/dashboard-nvim",
    lazy = false,
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
      
███╗   ██╗███████╗██████╗ ██╗   ██╗██╗      █████╗ 
████╗  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔══██╗
██╔██╗ ██║█████╗  ██████╔╝██║   ██║██║     ███████║
██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║
██║ ╚████║███████╗██████╔╝╚██████╔╝███████╗██║  ██║
╚═╝  ╚═══╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                   
      ]]

      logo = string.rep("\n", 5) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
  -- {
  --   "SmiteshP/nvim-navic",
  --   opts = function()
  --     return {
  --       lsp = {
  --         auto_attach = true,
  --         preference = { "volar" },
  --       },
  --     }
  --   end,
  -- },
  -- VS Code like winbar
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
    },
    config = function()
      require("barbecue").setup({
        create_autocmd = false, -- prevent barbecue from updating itself automatically
      })

      vim.api.nvim_create_autocmd({
        "WinScrolled", -- or WinResized on NVIM-v0.9 and higher
        "BufWinEnter",
        "CursorHold",
        "InsertLeave",

        -- include this if you have set `show_modified` to `true`
        -- "BufModifiedSet",
      }, {
        group = vim.api.nvim_create_augroup("barbecue.updater", {}),
        callback = function()
          require("barbecue.ui").update()
        end,
      })
    end,
  },
}
