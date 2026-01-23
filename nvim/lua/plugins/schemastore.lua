---@module "lazy"
---@type LazyPluginSpec
return {
  "b0o/schemastore.nvim",
  ft = { "json", "jsonc" },
  config = function()
    local config = vim.lsp.config.jsonls
    config.settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        format = { enable = true },
        validate = { enable = true },
      },
    }
    vim.lsp.config("jsonls", config)
    vim.lsp.enable("jsonls")
  end
}
