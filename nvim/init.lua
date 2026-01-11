-- init.lua - Neovim Configuration in Lua
-- Converted from vimrc

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- XDG environment variables
local config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand("$HOME/.config")
local data_home = vim.env.XDG_DATA_HOME or vim.fn.expand("$HOME/.local/share")
vim.env.CONFIG = config_home
vim.env.DATA = data_home

-- Basic settings
vim.opt.backspace = { "indent", "eol", "start" } -- allow backspacing over everything in insert mode

-- Backup settings
vim.opt.backup = false   -- do not keep a backup file, use versions instead
vim.opt.history = 10000  -- keep 200 lines of command line history
vim.opt.ruler = true     -- show the cursor position all the time
vim.opt.showcmd = true   -- display incomplete commands
vim.opt.incsearch = true -- do incremental searching

-- Key mappings
-- Don"t use Ex mode, use Q for formatting
vim.keymap.set("n", "Q", "gq", { noremap = true })

-- CTRL-U in insert mode deletes a lot. Use CTRL-G u to first break undo,
-- so that you can undo CTRL-U after inserting a line break.
vim.keymap.set("i", "<C-U>", "<C-G>u<C-U>", { noremap = true })

-- Mouse support
if vim.fn.has("mouse") == 1 then
  vim.opt.mouse = "a"
end

vim.opt.autoindent = true -- always set autoindenting on

-- DiffOrig command
if vim.fn.exists(":DiffOrig") == 0 then
  vim.api.nvim_create_user_command("DiffOrig", function()
    vim.cmd("vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis")
  end, {})
end

-- Set filetype for specific extensions
vim.filetype.add({
  extension = {
    sage = "python",
    pyx = "python",
    spyx = "python",
  },
})

-- Plugin and theme settings
-- vim.g.molokai_original = 1

-- Editor settings
vim.opt.expandtab = true          -- use spaces instead of tabs
vim.opt.tabstop = 2               -- number of spaces tabs count for
vim.opt.softtabstop = 2           -- number of spaces tabs count for in insert mode
vim.opt.shiftwidth = 2            -- size of an indent
vim.opt.smartindent = true        -- smart autoindenting
vim.opt.termguicolors = true      -- enable 24-bit RGB colors (replaces t_Co=256)
vim.opt.backup = false            -- disable backup (overrides earlier setting)
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.number = true             -- show line numbers

-- Paste toggle (F5 key)
vim.keymap.set("n", "<F5>", ":set paste!<CR>", { silent = true, noremap = true })
vim.keymap.set("i", "<F5>", "<ESC>:set paste!<CR>i", { silent = true, noremap = true })

-- Key remappings
vim.keymap.set("i", "<C-]>", "<ESC>", { noremap = true })
vim.keymap.set("v", "<C-]>", "<ESC>", { noremap = true })
vim.keymap.set("n", "<S-H>", "0", { noremap = true })      -- Shift+H to beginning of line
vim.keymap.set("n", "<S-L>", "$", { noremap = true })      -- Shift+L to end of line
vim.keymap.set("n", "m", "%", { noremap = true })          -- m to match brackets
vim.keymap.set("c", "<C-P>", "<Up>", { noremap = true })   -- Ctrl+P for command history up
vim.keymap.set("c", "<C-N>", "<Down>", { noremap = true }) -- Ctrl+N for command history down

-- Copy to system clipboard with Ctrl+C in visual mode
vim.keymap.set("v", "<C-C>", ":w !xsel -ib<CR><CR>", { noremap = true })

-- lazy.vim
require("config.lazy")
require("config.lsp")
require("config.binary")
