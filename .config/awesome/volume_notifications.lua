local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local constants = require("constants")

local _last_notif = nil
local _last_notif_time = 0

_volume_notif_template = {
    widget = wibox.container.constraint,
    width = dpi(400),
    height = dpi(100), 
    strategy = "max",
    {
        widget = naughty.container.background,
        id = "background_role",
        {
            widget = wibox.container.margin,
            margins = 10,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = 1,
                fill_space = false,
                naughty.widget.icon,
                naughty.widget.title,
            }
        }
    }
}

function vol_str(volume)
    local n_bars = volume // 5
    return "<b>┣" .. string.rep("━", n_bars) .. 
        string.rep(" ", 20 - n_bars) .. "┫ "  ..
        string.format("%3d", volume) .. "</b>"
end

function vol_icon(volume)
    local volume = tonumber(volume)
    if volume < 25 then
        return constants.status_icons_dir .. "notification-audio-volume-low.svg"
    elseif volume < 75 then
        return constants.status_icons_dir .. "notification-audio-volume-medium.svg"
    else
        return constants.status_icons_dir .. "notification-audio-volume-high.svg"
    end
end

function volume_notif()
    local muted_icon = constants.status_icons_dir .. "notification-audio-volume-muted.svg"
    awful.spawn.easy_async("pamixer --get-mute", function(stdout)
        local muted = stdout
        awful.spawn.easy_async("pamixer --get-volume", function(stdout)
            local curr_time = os.time()
            if curr_time - _last_notif_time < constants.notif_timeout then
                _last_notif.title = vol_str(stdout)
                _last_notif.icon = muted == "true\n" and muted_icon or vol_icon(stdout) 
                _last_notif_time = curr_time
            else
                _last_notif_time = curr_time
                _last_notif = naughty.notification{
                    title = vol_str(stdout),
                    icon = _muted == "true\n" and muted_icon or vol_icon(stdout),
                    font = constants.monofont,
                    app_name = constants.notif_app_name,
                }
            end
        end)
    end)
end