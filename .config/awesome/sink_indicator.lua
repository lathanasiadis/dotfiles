local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local constants = require("constants")
local sinks = constants.sinks

local sinkbuttons = {
    speakers = "",
    headphones = ""
}

local curr_sink
local ret
ret = wibox.widget{
    widget = wibox.widget.textbox,
    font = constants.iconfont,
    text = sinkbuttons.speakers,
    buttons = {
        awful.button({}, 1, nil, function()
            if ret.text == sinkbuttons.speakers then
                awful.spawn.easy_async(
                    "pactl set-default-sink " .. sinks.headphones,
                    function(out, err, reason, code)
                        if code == 0 then
                            ret.text = sinkbuttons.headphones
                        end
                    end)
            else
                awful.spawn.easy_async(
                    "pactl set-default-sink " .. sinks.speakers,
                    function(out, err, reason, code)
                        if code == 0 then
                            ret.text = sinkbuttons.speakers
                        end
                    end)
            end
        end)
    }
}

return ret