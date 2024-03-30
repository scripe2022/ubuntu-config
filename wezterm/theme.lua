local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
	config.colors = {
		foreground = "#ffffff",
		background = "#300a24",

		cursor_bg = "#4c4f6a",
		cursor_fg = "#eff1f6",
		cursor_border = "#300a24",
		selection_fg = "#300a24",
		selection_bg = "#b4d5ff",

		-- The color of the scrollbar "thumb"; the portion that represents the current viewport
		scrollbar_thumb = "#222222",

		-- The color of the split lines between panes
		split = "#444444",

		brights = {
			"#171421",
			"#c01c28",
			"#26a269",
			"#a2734c",
			"#12488b",
			"#a347ba",
			"#2aa1b3",
			"#d0cfcc",
		},
		ansi = {
			"#5e5c64",
			"#f66151",
			"#33d17a",
			"#e9ad0c",
			"#2a7bde",
			"#c061cb",
			"#33c7de",
			"#ffffff",
		},

		-- indexed = { [136] = "#af8700" },
		-- compose_cursor = "orange",
		-- copy_mode_active_highlight_bg = { Color = "#000000" },
		-- copy_mode_active_highlight_fg = { AnsiColor = "Black" },
		-- copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
		-- copy_mode_inactive_highlight_fg = { AnsiColor = "White" },
		--
		-- quick_select_label_bg = { Color = "peru" },
		-- quick_select_label_fg = { Color = "#ffffff" },
		-- quick_select_match_bg = { AnsiColor = "Navy" },
		-- quick_select_match_fg = { Color = "#ffffff" },
	}

    -- config.font_rules = {
    --     intensity = "Bold",
    --     font = wezterm.font({"DejaVuSansM Nerd Font Mono"}),
    -- }
	config.font = wezterm.font_with_fallback({
		"DejaVuSansM Nerd Font Mono",
		"DejaVuSansM Nerd Font Mono Bold",
		"DejaVuSansM Nerd Font Mono Oblique",
		"DejaVuSansM Nerd Font Mono Bold Oblique",
	})
end

return module
