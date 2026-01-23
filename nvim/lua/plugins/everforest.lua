---@module 'lazy'
---@type LazyPluginSpec
return {
  "sainnhe/everforest",
  lazy = false,
  priority = 1000,
  config = function()
    vim.g.everforest_background = "hard"
    vim.g.everforest_ui_contrast = "high"
    vim.g.everforest_dim_inactive_windows = true
    vim.g.everforest_diagnostic_virtual_text = true
    vim.cmd.colorscheme "everforest"
  end,
}
