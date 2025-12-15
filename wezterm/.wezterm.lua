local wezterm = require("wezterm")
local act = wezterm.action

-- Path to custom colors file
local colors_path = wezterm.home_dir .. "/.wezterm-colors.lua"

-- Add colors file to watch list for hot reload
wezterm.add_to_config_reload_watch_list(colors_path)

-- Try to load custom colors from external file
local function load_colors()
  local f = io.open(colors_path, "r")
  if f then
    f:close()
    local ok, colors = pcall(dofile, colors_path)
    if ok then
      return colors
    end
  end
  return nil
end

local config = {
  front_end = "OpenGL",
  font = wezterm.font("JetBrainsMono Nerd Font Mono"),
  font_size = 14,
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
  keys = {
    { key = "Enter", mods = "ALT", action = act.DisableDefaultAssignment },
  },
}

-- Apply custom colors or fallback to Catppuccin Mocha
local custom_colors = load_colors()
if custom_colors then
  config.colors = custom_colors
else
  config.color_scheme = "Catppuccin Mocha"
end

return config
