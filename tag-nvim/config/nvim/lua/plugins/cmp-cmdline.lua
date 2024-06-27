return {
  {
    "hrsh7th/cmp-cmdline",
    lazy = true,
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
    },
    opts = function()
      local cmp = require("cmp")
      cmp.setup.cmdline(":", {
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
}
