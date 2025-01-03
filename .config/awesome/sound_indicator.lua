local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local constants = require("constants")

local sinks = {
    speakers = "alsa_output.pci-0000_00_1f.3.analog-stereo",
    headphones = "alsa_output.usb-Kingston_HyperX_Virtual_Surround_Sound_00000000-00.analog-stereo"
}
local sinkbuttons = {
    speakers = "",
    headphones = ""
}

sinkindicator = awful.widget.watch("bash -c 'pactl get-default-sink'", 1,
    function(widget, stdout)
        if stdout:sub(1,#stdout - 1) == sinks.speakers then
            widget.text = sinkbuttons.speakers
        else
            widget.text = sinkbuttons.headphones
        end
        return
    end)

sinkindicator.font = constants.iconfont

sinkindicator:buttons(gears.table.join(
    sinkindicator:buttons(),
    awful.button({}, 1, nil, function ()
        if sinkindicator.text == sinkbuttons.speakers then
            sinkindicator.text = sinkbuttons.headphones
            awful.spawn("pactl set-default-sink " .. sinks.headphones)
        else
            sinkindicator.text = sinkbuttons.speakers
            awful.spawn("pactl set-default-sink " .. sinks.speakers)
        end
    end)
))

return sinkindicator