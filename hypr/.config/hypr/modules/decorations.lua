-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 15,

		border_size = 3,

		col = {
			active_border = { colors = { "rgba(35a77cff)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		-- Change transparency of focused and unfocused windows
		active_opacity = 0.9,
		inactive_opacity = 0.87,
		fullscreen_opacity = 1,

		rounding = 0,

		shadow = {
			enabled = false,
			range = 8,
			render_power = 3,
			color = 0x0a0a0add,
		},

		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			contrast = 0.92,
			brightness = 0.88,
			vibrancy = 0.12,
			vibrancy_darkness = 0.25,
			noise = 0.045,
			ignore_opacity = true,
			new_optimizations = true,
		},
	},

	animations = {
		enabled = true,
	},
})
