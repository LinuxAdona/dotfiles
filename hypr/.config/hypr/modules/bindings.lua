---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "ghostty"
local fileManager = "nautilus"
local menu = "rofi -show drun -theme ~/.config/rofi/config.rasi"
local browser = "zen-browser"

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + W", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen_state({ internal = 1, client = 0, action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch.sh"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

for i = 1, 5 do
	hl.dsp.workspace.move({ workspace = i, monitor = "eDP-1" })
end

for i = 6, 10 do
	hl.dsp.workspace.move({ workspace = i, monitor = "HDMI-A-1" })
end

-- Move workspaces to other monitors
hl.bind(mainMod .. " + CTRL + H", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.workspace.move({ monitor = "d" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume 5"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume -5"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("pamixer --default-source -t && swayosd-client --input-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness +5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -5"), { locked = true, repeating = true })

hl.bind(
	"CAPS_LOCK",
	hl.dsp.exec_cmd("swayosd-client --caps-lock"),
	{ locked = true, repeating = false, release = true }
)

hl.bind("NUM_LOCK", hl.dsp.exec_cmd("swayosd-client --num-lock"), { locked = true, repeating = false, release = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl prev"), { locked = true })

-- Notication Center
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("swaync-client -t"))

-- Clipboard Manager
hl.bind(
	mainMod .. " + SHIFT + V",
	hl.dsp.exec_cmd(
		'cliphist list | rofi -dmenu -display-columns 2 -p "" -theme "$HOME/.config/rofi/config.rasi" | cliphist decode | wl-copy'
	)
)

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots/"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m output -m eDP-1 -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + SHIFT + F12", hl.dsp.exec_cmd("hyprshot -m output -m HDMI-A-1 -o ~/Pictures/Screenshots"))

-- Transparency Toggle
hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))

-- Wallpaper Switcher
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh --cycle"))

-- Logout Menu
hl.bind(mainMod .. " + CTRL + DELETE", hl.dsp.exec_cmd("wlogout -m 150 -c 10 -r 10"))

-- Color Picker
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Waybar Toggle
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("pkill -USR1 waybar"))

-- Network Manager
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("ghostty -e impala"))
