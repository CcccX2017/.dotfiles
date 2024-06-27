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
  --navic
  {
    "SmiteshP/nvim-navic",
    lazy = false,
    opts = {
      lsp = {
        auto_attach = true,
        preference = nil,
      },
      icons = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = " ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = " ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      },
    },
  },
  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.winbar = {
        lualine_c = {
          {
            "navic",
            color_correction = nil,
            navic_opts = nil,
          },
        },
      }
    end,
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
}
