local wezterm = require("wezterm")

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
}
