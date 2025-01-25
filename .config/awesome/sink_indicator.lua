local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local constants = require("constants")
local widget_template = require("monitors").template
local sinks = constants.sinks
local naughty = require("naughty")
local sinkbuttons = {
    speakers = "",
    headphones = ""
}

local template = "<span foreground=\"%s\"><b>%s</b></span>"

local curr_sink
local ret
ret = widget_template(constants.overlay2, constants.iconfont, sinkbuttons.speakers)
ret.buttons = {
    awful.button({}, 1, nil, function()
        ret:emit_signal("sinks::change")
    end)
}
ret:connect_signal("sinks::change", function (c)
    local text_widget = c:get_children_by_id("w_text")[1] 
    if text_widget.text == sinkbuttons.speakers then
        awful.spawn.easy_async(
            "pactl set-default-sink " .. sinks.headphones,
            function(out, err, reason, code)
                if code == 0 then
                    text_widget.text = sinkbuttons.headphones
                end
            end)
    else
        awful.spawn.easy_async(
            "pactl set-default-sink " .. sinks.speakers,
            function(out, err, reason, code)
                if code == 0 then
                    text_widget.text = sinkbuttons.speakers
                end
            end)
    end
end)

return ret