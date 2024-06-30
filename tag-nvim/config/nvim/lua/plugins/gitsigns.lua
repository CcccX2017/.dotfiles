return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    opts.current_line_blame = true
  end,
}
