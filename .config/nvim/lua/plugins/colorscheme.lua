return {
  {
    "folke/tokyonight.nvim",
    opts = function(_, opts)
      local lazywal = require("themes.lazywal")
      opts.on_colors = function(colors)
        for k, v in pairs(lazywal) do
          if type(v) == "table" then
            colors[k] = vim.tbl_deep_extend("force", colors[k] or {}, v)
          else
            colors[k] = v
          end
        end
      end
    end,
  },
}