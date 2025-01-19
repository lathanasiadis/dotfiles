local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local constants = require("constants")

-- Last notification object and the time it was displayed
local last = {
    volume = {
        n = nil,
        t = 0
    },
    brightness = {
        n = nil, 
        t = 0
    }
}

local ret = {}
ret.notif = {}

local function metric_str(metric)
    local n_bars = metric // 5
    -- math.floor because string format fails for %nd when the number 
    -- doesn't have an integer representation
    return "<b>┣" .. string.rep("━", n_bars) .. 
        string.rep(" ", 20 - n_bars) .. "┫ "  ..
        string.format("%3d", math.floor(metric)) .. "</b>"
end

local function notif_icon(metric, type)
    local metric = tonumber(metric)
    local tabl = (type == "volume") and constants.icons.volume or constants.icons.brightness
    if metric < 25 then
        return tabl.low
    elseif metric < 75 then
        return tabl.medium
    else
        return tabl.high
    end
end

function ret.notif.volume()
    awful.spawn.easy_async("pamixer --get-mute", function(stdout)
        local muted = stdout
        awful.spawn.easy_async("pamixer --get-volume", function(stdout)
            local curr_time = os.time()
            if curr_time - last.volume.t < constants.notif_timeout then
                last.volume.n.title = metric_str(stdout)
                last.volume.n.icon = muted == "true\n" and constants.icons.volume.muted or notif_icon(stdout, "volume") 
                last.volume.t = curr_time
            else
                last.volume.t = curr_time
                last.volume.n = naughty.notification{
                    title = metric_str(stdout),
                    icon = _muted == "true\n" and constants.icons.volume.muted or notif_icon(stdout, "volume"),
                    font = constants.monofont,
                    app_name = constants.notif_app_name,
                }
            end
        end)
    end)
end

function ret.notif.brightness()
    awful.spawn.easy_async("xbacklight", function(stdout)
        local curr_time = os.time()
        if curr_time - last.brightness.t < constants.notif_timeout then
            last.brightness.n.title = metric_str(stdout)
            last.brightness.n.icon = notif_icon(stdout, "brightness") 
            last.brightness.t = curr_time
        else
            last.brightness.t = curr_time
            last.brightness.n = naughty.notification{
                title = metric_str(stdout),
                icon = notif_icon(stdout, "brightness"),
                font = constants.monofont,
                app_name = constants.notif_app_name,
            }
        end
    end)
end

ret.template = {
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

return ret