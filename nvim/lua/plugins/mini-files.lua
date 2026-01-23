---@module "lazy"
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
  config = function(_, opts)
    require('mini.files').setup(opts)

    local map_split = function(buf_id, key, direction)
      local action = function()
        local MiniFiles = require('mini.files')
        -- Make new window and set it as target
        local cur_target = MiniFiles.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
          vim.cmd(direction .. ' split')
          return vim.api.nvim_get_current_win()
        end)

        MiniFiles.set_target_window(new_target)
      end

      local desc = 'Split ' .. direction
      vim.keymap.set('n', key, action, { buffer = buf_id, desc = desc })
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        map_split(buf_id, '<C-s>', 'belowright horizontal')
        map_split(buf_id, '<C-v>', 'belowright vertical')
        map_split(buf_id, '<C-t>', 'tab')
      end,
    })
  end
}
