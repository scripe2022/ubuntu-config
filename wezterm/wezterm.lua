local wezterm = require("wezterm")
local config = {}
local theme = require("theme")
theme.apply_to_config(config)

config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.font_size = 15.0
config.freetype_load_flags = "NO_HINTING"
config.initial_rows = 36
config.initial_cols = 120
-- config.freetype_load_target = 'Light'
-- config.freetype_render_target = 'HorizontalLcd'
-- config.front_end = "WebGpu"
-- config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 1.0,
}

config.colors.tab_bar = {
	-- font = wezterm.font { family = 'DejaVuSansM Nerd Font Mono' },
	-- active_titlebar_bg = "#300a24",
	-- inactive_titlebar_bg = "#300a24"
	background = "#300a24",
	inactive_tab = {
		fg_color = "#eeeeee",
		bg_color = "#300a24",
		intensity = "Bold",
		italic = false,
	},
	active_tab = {
		fg_color = "#300a24",
		bg_color = "#eeeeee",
		intensity = "Bold",
		italic = true,
	},
}

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "CTRL|SHIFT" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "CTRL|SHIFT" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.keys = {
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),

	{
		key = "|",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "Enter",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "x", mods = "CTRL", action = wezterm.action.ActivateCopyMode },
	{
		key = "F11",
		action = wezterm.action.ToggleFullScreen,
	},
    -- {
    --     key = ".",
    --     mods = "CTRL",
    --     action = wezterm.action.tab:rotate_clockwise(),
    -- }
}

for i = 1, 8 do
	-- CTRL+ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
