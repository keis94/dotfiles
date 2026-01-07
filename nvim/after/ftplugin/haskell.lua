--local ht = require('haskell-tools')
--local bufnr = vim.api.nvim_get_current_buf()
--local opts = { noremap = true, silent = true, buffer = bufnr, }
--
---- Hoogle search for the type signature of the definition under the cursor
--vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
---- Evaluate all code snippets
--vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
---- Toggle a GHCi repl for the current package
--vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
---- Toggle a GHCi repl for the current buffer
--vim.keymap.set('n', '<leader>rf', function()
--  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
--end, opts)
--vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
--vim.keymap.set('n', '<space>a', '<Plug>HaskellHoverAction')

-- Haskellファイル固有のキーマップ
local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr }

-- === LSP基本機能 ===
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, opts)

-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)

-- === 診断機能 ===
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>dl', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, opts)

-- === Haskell Tools固有機能 ===
-- Hoogleサーチ
vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
vim.keymap.set('n', '<leader>hh', function()
  ht.hoogle.telescope_hoogle()
end, opts)

-- コード評価（HLSのcode lenses使用）
vim.keymap.set('n', '<leader>ea', ht.lsp.buf_eval_all, opts)
--vim.keymap.set('v', '<leader>er', ht.lsp.buf_eval_range, opts)

-- REPL操作
vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
vim.keymap.set('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
vim.keymap.set('n', '<leader>rl', function()
  ht.repl.reload()
end, opts)

-- プロジェクト管理
vim.keymap.set('n', '<leader>hp', function()
  ht.project.open_project_file()
end, opts)

-- HLS管理コマンド
vim.keymap.set('n', '<leader>hls', '<cmd>HlsStart<cr>', opts)
vim.keymap.set('n', '<leader>hlt', '<cmd>HlsStop<cr>', opts)
vim.keymap.set('n', '<leader>hlr', '<cmd>HlsRestart<cr>', opts)

-- ログ表示
vim.keymap.set('n', '<leader>hll', '<cmd>Haskell log openLog<cr>', opts)
vim.keymap.set('n', '<leader>htl', '<cmd>Haskell log openHlsLog<cr>', opts)

-- ホバーアクション
vim.keymap.set('n', '<leader>ha', '<Plug>HaskellHoverAction', opts)
