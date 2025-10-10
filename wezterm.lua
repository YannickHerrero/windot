local wezterm = require("wezterm")

return {
	front_end = "OpenGL",
	font = wezterm.font("JetBrainsMono Nerd Font Mono"),
	color_scheme = "Catppuccin Mocha",
	window_decorations = "RESIZE",
	hide_tab_bar_if_only_one_tab = true,
	window_background_opacity = 0.95,
	window_close_confirmation = "NeverPrompt",

	-- Fix search/selection colors for better visibility
	colors = {
		-- Selection colors (when you select text)
		selection_fg = "#cdd6f4", -- Catppuccin text
		selection_bg = "#45475a", -- Catppuccin surface1

		-- Search match highlighting
		search_result_fg = "#1e1e2e", -- Catppuccin base (dark)
		search_result_bg = "#f9e2af", -- Catppuccin yellow (visible but not harsh)

		-- Current search match (the one you're on)
		search_result_fg_current = "#1e1e2e", -- Catppuccin base
		search_result_bg_current = "#fab387", -- Catppuccin peach (stands out more)
	},

	wsl_domains = {
		{
			name = "WSL:Ubuntu",
			distribution = "Ubuntu",
			default_cwd = "~",
		},
	},
	default_domain = "WSL:Ubuntu",
}
