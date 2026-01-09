return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = { 
    flavour = "mocha", -- auto, latte, frappe, macchiato, mocha
    background = { -- :h background
      light = "mocha",
      dark = "mocha",
    },
    dim_inactive = {
      enabled = true,
      shade = "light",
      percentage = 0.9,
    },
    auto_integrations = true,
    color_overrides = {
      mocha = {
        -- ref.) https://catppuccin.com/palette/
        -- base = "#11111b" -- crust for mocha
        base = "#181825" -- mantle for mocha
      },
    },
    custom_highlights = function(colors)
      return {
        Comment = { fg = colors.mantle, bg = colors.surface2 },
      }
    end,
  },
  init = function () 
    -- vim.cmd.colorscheme "catppuccin"
  end
}
