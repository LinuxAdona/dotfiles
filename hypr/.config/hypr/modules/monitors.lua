------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Two layouts, toggled with ALT + CTRL + M, which runs
-- ~/.config/hypr/scripts/monitor-mode.sh to rewrite the `mode` line below and
-- reload Hyprland:
--
--   extend    HDMI-A-1 sits to the right of the laptop panel
--   mirror    HDMI-A-1 duplicates the laptop panel

-- This line is rewritten by scripts/monitor-mode.sh
local mode = "extend"

local LAPTOP = "eDP-1"
local EXTERNAL = "HDMI-A-1"

hl.monitor({
	output = LAPTOP,
	mode = "1920x1080@60",
	position = "0x0",
	scale = "1",
})

if mode == "mirror" then
	hl.monitor({
		output = EXTERNAL,
		mode = "preferred",
		position = "auto",
		scale = "1",
		mirror = LAPTOP,
	})
else
	-- Placed at the laptop panel's width so it extends to the right of it
	hl.monitor({
		output = EXTERNAL,
		mode = "1920x1080@100",
		position = "1920x0",
		scale = "1",
	})
end
