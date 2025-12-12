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

      -- Centralized highlight overrides using base16 colors
      -- This ensures all UI elements respect the current theme
      local function set_custom_highlights()
        local c = require("base16-colorscheme").colors
        if not c then return end

        local hl = vim.api.nvim_set_hl

        -- Dashboard highlights (muted, non-distracting)
        hl(0, "DashboardHeader", { fg = c.base04 })
        hl(0, "DashboardFooter", { fg = c.base03 })
        hl(0, "DashboardCenter", { fg = c.base05 })
        hl(0, "DashboardShortCut", { fg = c.base0D })
        hl(0, "DashboardIcon", { fg = c.base0D })
        hl(0, "DashboardDesc", { fg = c.base05 })
        hl(0, "DashboardKey", { fg = c.base0E })

        -- Neo-tree highlights
        hl(0, "NeoTreeDirectoryIcon", { fg = c.base0D })
        hl(0, "NeoTreeDirectoryName", { fg = c.base0D })
        hl(0, "NeoTreeFileName", { fg = c.base05 })
        hl(0, "NeoTreeFileIcon", { fg = c.base05 })
        hl(0, "NeoTreeRootName", { fg = c.base0E, bold = true })
        hl(0, "NeoTreeGitAdded", { fg = c.base0B })
        hl(0, "NeoTreeGitModified", { fg = c.base0A })
        hl(0, "NeoTreeGitDeleted", { fg = c.base08 })
        hl(0, "NeoTreeGitUntracked", { fg = c.base03 })
        hl(0, "NeoTreeIndentMarker", { fg = c.base02 })
        hl(0, "NeoTreeExpander", { fg = c.base03 })
        hl(0, "NeoTreeNormal", { fg = c.base05, bg = c.base00 })
        hl(0, "NeoTreeNormalNC", { fg = c.base05, bg = c.base00 })
        hl(0, "NeoTreeCursorLine", { bg = c.base01 })

        -- Telescope highlights
        hl(0, "TelescopeMatching", { fg = c.base0A, bold = true })
        hl(0, "TelescopeSelection", { fg = c.base05, bg = c.base01 })
        hl(0, "TelescopeSelectionCaret", { fg = c.base0E, bg = c.base01 })
        hl(0, "TelescopeMultiSelection", { fg = c.base0B, bg = c.base01 })
        hl(0, "TelescopePromptPrefix", { fg = c.base0D })
        hl(0, "TelescopePromptCounter", { fg = c.base03 })
        hl(0, "TelescopePromptNormal", { fg = c.base05, bg = c.base00 })
        hl(0, "TelescopeResultsNormal", { fg = c.base05, bg = c.base00 })
        hl(0, "TelescopePreviewNormal", { fg = c.base05, bg = c.base00 })
        hl(0, "TelescopeBorder", { fg = c.base02, bg = c.base00 })
        hl(0, "TelescopePromptBorder", { fg = c.base02, bg = c.base00 })
        hl(0, "TelescopeResultsBorder", { fg = c.base02, bg = c.base00 })
        hl(0, "TelescopePreviewBorder", { fg = c.base02, bg = c.base00 })
        hl(0, "TelescopeTitle", { fg = c.base0D, bold = true })
        hl(0, "TelescopePromptTitle", { fg = c.base0D, bold = true })
        hl(0, "TelescopeResultsTitle", { fg = c.base0D, bold = true })
        hl(0, "TelescopePreviewTitle", { fg = c.base0D, bold = true })
      end

      -- Apply highlights immediately
      set_custom_highlights()

      -- Reapply when colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = set_custom_highlights,
      })
    end,
  },
}
