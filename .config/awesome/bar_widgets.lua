local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local constants = require("constants")

local template = "<span foreground=\"%s\"><b>%s %d%s</b></span>"

local M = {}

function M.rect()
    return function(cr, width, height)
        return gears.shape.rounded_rect(cr, width, height, 3)
    end
end

function M.widget(color, font, init, text_widget)
    local inner_widget
    if text_widget ~= nil then
        inner_widget = text_widget
    else
        inner_widget = wibox.widget.textbox
    end

    return wibox.widget{
        widget = wibox.container.background,
        id = "w_bg",
        shape = M.rect(),
        bg = color,
        {
            widget = wibox.container.margin,
            id = "w_margins",
            margins = {
                left = 6,
                right = 6
            },
            {
                widget = inner_widget,
                id = "w_text",
                font = font,
                markup = init,
            }
            
        }
    }
end

function M.monitor(command, timeout, unit, compare_op, thresholds, icons)
    return awful.widget.watch({"bash", "-c", command}, timeout,
        function(widget, stdout)
            local stat = tonumber(stdout)
            local color, icon
            if compare_op(stat, thresholds[1]) then
                color = constants.green
                icon = icons[1]
            elseif compare_op(stat, thresholds[2]) then
                color = constants.yellow
                icon = icons[2]
            else
                color = constants.red
                icon = icons[3]
            end
            widget:get_children_by_id("w_text")[1].markup = template:format(constants.base, icon, stat, unit)
            widget:get_children_by_id("w_bg")[1].bg = color
        end,
        M.widget(constants.green, constants.iconfont, "", wibox.widget{
            widget = wibox.widget.textbox,
            id = "w_text",
            font = font,
            text = init,
        })
    )
end

-- simpler template for widgets that only display icons
M.str_template = '<span foreground="' .. constants.base .. '">%s</span>'

return M