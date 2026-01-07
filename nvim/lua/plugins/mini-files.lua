---@type LazyPluginSpec
return {
  "nvim-mini/mini.files",
  version = "*",
  keys = {
    {
      "<leader>e",
      function() require("mini.files").open() end,
      desc = "Open file browser",
    },
    {
      "<leader>E",
      function() require("mini.files").open(vim.api.nvim_buf_get_name(0)) end,
      desc = "Open file browser (current file)",
    },
  },
  opts = {},
}
