---@module 'lazy'
---@type LazyPluginSpec
return {
  "mrcjkb/haskell-tools.nvim",
  version = "^6", -- Recommended
  lazy = false, -- This plugin is already lazy
  ft = { "haskell" },
  config = function()
    -- haskell-tools.nvimの設定
    vim.g.haskell_tools = {
      -- HLS（Haskell Language Server）設定
      hls = {
        -- HLSの自動起動
        auto_attach = true,

        -- デバッグ用ログ設定
        debug = false,

        -- LSPクライアントのattach時の処理
        on_attach = function(client, bufnr)
          -- カスタムな処理があれば記述
          print("HLS attached to buffer " .. bufnr)
          vim.diagnostic.config({
            virtual_text = true,          -- 行末に診断テキスト表示
            signs = true,                 -- 行番号横にサイン表示
            underline = true,             -- エラー箇所に下線
            update_in_insert = true,      -- 挿入モード中も更新
            severity_sort = true,         -- 重要度順でソート
            float = {
              focusable = false,
              style = "minimal",
              border = "rounded",
              source = "always",          -- ソース情報も表示
              header = "",
              prefix = "",
            },
          })

          -- -- 自動的にfloating windowで詳細を表示
          -- vim.api.nvim_create_autocmd("CursorHold", {
          --   buffer = bufnr,
          --   callback = function()
          --     local opts = {
          --       focusable = false,
          --       close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          --       border = 'rounded',
          --       source = 'always',
          --       prefix = ' ',
          --       scope = 'cursor',
          --     }
          --     vim.diagnostic.open_float(nil, opts)
          --   end
          -- })

          -- カーソル移動時の自動更新間隔設定
          vim.opt.updatetime = 300
        end,

        settings = {
          haskell = {
            formattingProvider = 'stylish-haskell', -- またはormolu, fourmolu
            hlintOn = true,
            checkProject = true,
            maxCompletions = 40,
            plugin = {
              -- 個別プラグインの診断設定
              hlint = {
                diagnosticsOn = true,
                codeLensOn = true,
              },
              -- ghcide = {
              --   completionsConfigOn = true,
              -- },
              -- eval = {
              --   config = {
              --     diff = true,
              --     exception = true,
              --   },
              -- },
            },
          },
        },
      },
    }
  end
}
