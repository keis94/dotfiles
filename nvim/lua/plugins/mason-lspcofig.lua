---@module 'lazy'
---@type LazyPluginSpec
return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
  opts = {
    ensure_installed = {
      "lua_ls",
      "bashls",
      "jsonls",
      "clangd",
      "pyright",
      "rust_analyzer",
    },

    automatic_enable = {
      -- enabled at schemastore.lua
      exclude = { "jsonls" }
    }
  },
}
