---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      workspace = {
        -- Loading everything slows it down, but lazydev.nvim broke suddenly, so this is workaround.
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = "Disable",
      },
    },
  },
}
