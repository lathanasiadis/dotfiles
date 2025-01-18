local awful = require("awful")
local naughty = require("naughty")
local constants = require("constants")

_last_notif = nil
_last_notif_time = 0

function vol_str(volume)
    local n_bars = math.floor(volume / 5)
    return "┣" .. string.rep("━", n_bars) .. string.rep(" ", 20 - n_bars) .. "┫" .. " " .. volume
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
                _last_notif.message = vol_str(stdout)
                _last_notif.icon = muted == "true\n" and muted_icon or vol_icon(stdout) 
                _last_notif_time = curr_time
            else
                _last_notif_time = curr_time
                _last_notif = naughty.notification{
                    message = vol_str(stdout),
                    icon = _muted == "true\n" and muted_icon or vol_icon(stdout),
                    font = constants.monofont,
                }
            end
        end)
    end)
end