---@module 'lazy'
---@type LazyPluginSpec
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>ff',  function() require('telescope.builtin').find_files() end,           desc = 'Telescope find files' },
    { '<leader>fg',  function() require('telescope.builtin').live_grep() end,            desc = 'Telescope live grep' },
    { '<leader>fb',  function() require('telescope.builtin').buffers() end,              desc = 'Telescope buffers' },
    { '<leader>fd',  function() require('telescope.builtin').diagnostics() end,          desc = 'Telescope diagnostics' },
    { '<leader>fh',  function() require('telescope.builtin').help_tags() end,            desc = 'Telescope help tags' },
    { '<leader>fr',  function() require('telescope.builtin').lsp_references() end,       desc = 'Telescope LSP references' },
    { '<leader>fi',  function() require('telescope.builtin').lsp_implementations() end,  desc = 'Telescope LSP implementations' },
    { '<leader>fD',  function() require('telescope.builtin').lsp_definitions() end,      desc = 'Telescope LSP definitions' },
    { '<leader>ftd', function() require('telescope.builtin').lsp_type_definitions() end, desc = 'Telescope LSP type definitions' },
    { '<leader>fkm', function() require('telescope.builtin').keymaps() end,              desc = 'Telescope normal mode keymappings' },
  },
}
