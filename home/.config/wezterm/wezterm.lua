local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0

config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true

-- Override indexed 256-colors so Claude Code's input backgrounds
-- blend with Rose Pine Moon's purple base instead of neutral gray.
config.colors = {
	indexed = {
		[233] = "#232136",
		[234] = "#2a273f",
		[235] = "#2a273f",
		[236] = "#393552",
		[237] = "#393552",
		[238] = "#393552",
	},
}

config.keys = {
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "LeftArrow", mods = "CMD|ALT", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CMD|ALT", action = wezterm.action.ActivateTabRelative(1) },
}

-- Dim unfocused windows so the active one stands out
wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	if window:is_focused() then
		overrides.window_background_opacity = 0.8
		overrides.foreground_text_hsb = nil
	else
		overrides.window_background_opacity = 0.62
		overrides.foreground_text_hsb = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
	end
	window:set_config_overrides(overrides)
end)

return config
