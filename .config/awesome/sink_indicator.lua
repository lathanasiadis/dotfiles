local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local n = require("naughty")
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
                    function()
                        ret.text = sinkbuttons.headphones
                    end)
            else
                awful.spawn.easy_async(
                    "pactl set-default-sink " .. sinks.speakers,
                    function()
                        ret.text = sinkbuttons.speakers
                    end)
            end
        end)
    }
}

return ret