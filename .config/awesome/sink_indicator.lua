local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local constants = require("constants")
local bar_widget = require("bar_widgets").widget
local bar_template = require("bar_widgets").str_template
local sinks = constants.sinks
local naughty = require("naughty")

local sinkbuttons = {
    speakers = "",
    headphones = ""
}

local curr_sink
local ret
ret = bar_widget(constants.sapphire, constants.iconfont,
    bar_template:format(sinkbuttons.speakers))
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
                    text_widget.markup = bar_template:format(sinkbuttons.headphones)
                end
            end)
    else
        awful.spawn.easy_async(
            "pactl set-default-sink " .. sinks.speakers,
            function(out, err, reason, code)
                if code == 0 then
                    text_widget.markup = bar_template:format(sinkbuttons.speakers)
                end
            end)
    end
end)

return ret