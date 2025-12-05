local wezterm = require("wezterm")
local act = wezterm.action

-- Format window title to include CWD for external scripts
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
  local cwd = pane.current_working_dir
  if cwd then
    -- cwd is a URL object, convert to string
    cwd = cwd.file_path or tostring(cwd)
    return "WezTerm: " .. cwd
  end
  return "WezTerm"
end)

return {
  front_end = "OpenGL",
  font = wezterm.font("JetBrainsMono Nerd Font Mono"),
  color_scheme = "Catppuccin Mocha",
  window_decorations = "RESIZE",
  hide_tab_bar_if_only_one_tab = true,
  window_background_opacity = 1,
  window_close_confirmation = "NeverPrompt",
  wsl_domains = {
    {
      name = "WSL:Ubuntu",
      distribution = "Ubuntu",
      default_cwd = "~",
    },
  },
  default_domain = "WSL:Ubuntu",

  -- Disable Alt+Enter so it passes through to AutoHotkey
  keys = {
    { key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },
  },
}
