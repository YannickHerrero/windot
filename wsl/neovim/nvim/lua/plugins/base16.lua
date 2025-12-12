return {
  {
    "RRethy/nvim-base16",
    lazy = false,
    priority = 1000,
    config = function()
      -- Try to load theme colors from generated file
      local ok, colors = pcall(require, "theme-colors")
      if ok and colors.base16 then
        require("base16-colorscheme").setup(colors.base16)
      else
        -- Fallback to built-in base16-default-dark
        vim.cmd.colorscheme("base16-default-dark")
      end
    end,
  },
}
