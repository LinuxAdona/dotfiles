-- This line is rewritten by `scripts/theme.sh`.
local flavour = "mocha"

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = { flavour = flavour },
    init = function()
      -- Keep 'background' in sync with the flavour, so Neovim's own defaults
      -- and any plugin that keys off it agree with the colorscheme.
      vim.o.background = flavour == "latte" and "light" or "dark"
    end,
  },

  -- LazyVim defaults to tokyonight; without this the catppuccin spec above is
  -- installed but never actually loaded.
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
