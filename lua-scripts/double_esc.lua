-- double_esc.lua
-- Place in: %APPDATA%\mpv\scripts\double_esc.lua
local mp = require 'mp'
local last_time = 0
local timeout = 0.28   -- tweak this (seconds). 0.25-0.35 is typical.
local active_timer = nil

local function single_action()
    -- only exit fullscreen / unmaximize if currently in that state
    local is_fs = mp.get_property_bool("fullscreen") or false
    local is_max = mp.get_property_bool("window-maximized") or false
    if is_fs then
        mp.commandv("set", "fullscreen", "no")
    elseif is_max then
        mp.commandv("set", "window-maximized", "no")
    end
end

local function esc_handler()
    local now = mp.get_time()
    if last_time == 0 or (now - last_time) > timeout then
        -- first press: start the timer waiting for possible second press
        last_time = now
        if active_timer then active_timer:kill() end
        active_timer = mp.add_timeout(timeout, function()
            single_action()
            last_time = 0
            active_timer = nil
        end)
    else
        -- second press within timeout -> double-press action (minimize)
        if active_timer then active_timer:kill() end
        last_time = 0
        active_timer = nil
        mp.command("cycle window-minimized")
    end
end

mp.add_key_binding("ESC", "double-esc", esc_handler)
