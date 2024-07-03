return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "shellcheck",
        "shfmt",
        "eslint-lsp",
        "css-lsp",
        "pyright",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "css",
        "scss",
      })
    end,
  },
}
