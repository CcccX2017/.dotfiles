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
}
