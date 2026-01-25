---@module 'lazy'
---@type LazyPluginSpec
return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets', 'onsails/lspkind.nvim', 'nvim-mini/mini.icons' },
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'default',
      ['C-space'] = {},
      ['<C-e>'] = { 'show', 'show_documentation', 'hide_documentation', 'fallback' },
      ['<Tab>'] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_and_accept()
          end
          if cmp.snippet_active() then
            return cmp.snippet_forward()
          end
          return false
        end,
        'snippet_forward',
        'fallback'
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.snippet_backward()
          end
          return false
        end,
        'snippet_backward',
        'fallback'
      },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = {
      documentation = {
        auto_show = true,
        window = { border = "rounded" }
      },
      menu = {
        border = "rounded",
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local mini_icon, _ = require("mini.icons").get(ctx.item.data.type, ctx.label)
                  if mini_icon then return mini_icon .. ctx.icon_gap end
                end

                local icon = require("lspkind").symbolic(ctx.kind)
                return icon .. ctx.icon_gap
              end,

              highlight = function(ctx)
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local mini_icon, mini_hl = require("mini.icons").get(ctx.item.data.type, ctx.label)
                  if mini_icon then return mini_hl end
                end
                return ctx.kind_hl
              end,
            },
            kind = {
              highlight = function(ctx)
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local mini_icon, mini_hl = require("mini.icons").get(ctx.item.data.type, ctx.label)
                  if mini_icon then return mini_hl end
                end
                return ctx.kind_hl
              end,
            }
          }
        }
      }
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
