local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local bar_widget = require("bar_widgets").widget
local constants = require("constants")

local curr_date = os.date("*t")
local curr_day = curr_date["day"]
local curr_month = curr_date["month"]
local curr_year = curr_date["year"]
local orig_month = curr_date["month"]
local orig_year = curr_date["year"]

local M = {}

M.clock = bar_widget(constants.lavender, constants.iconfont, _,
    wibox.widget {
        widget = wibox.widget.textclock,
        format = "<span foreground='" .. constants.base .. "'><b> %H:%M</b></span>",
    }
)

M.calendar = bar_widget(constants.mauve, constants.iconfont, _,
    wibox.widget {
        widget = wibox.widget.textclock,
        format = "<span foreground='" .. constants.base .. "'><b> %d/%m/%y</b></span>",
    }
)

local calpop = awful.popup {
    widget = {
        widget = wibox.widget.calendar.month,
        date = curr_date,
        font = constants.font
    },
    border_width = dpi(2),
    border_color = constants.blue,
    x = 1700,
    y = 50,
    ontop = true,
    visible = false
}

M.calendar:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        if calpop.visible then
            calpop.visible = false
            awful.keygrabber.stop(grabber)
        else
            -- Reset to current date
            curr_date = os.date("*t")
            calpop.widget.date = curr_date
            curr_month = curr_date["month"]
            curr_year = curr_date["year"]
            calpop.visible = true
            -- Controls to show next/prev month and close the popup
            grabber = awful.keygrabber.run(function(mod, key, event)
                if event == "release" then return end
                if key == "Right" then
                    calpop.visible = false
                    curr_month = curr_month + 1
                    if curr_month == 13 then
                        curr_month = 1
                        curr_year = curr_year + 1
                    end
                    calpop.widget.date = {month = curr_month, year=curr_year}
                    calpop.visible = true
                elseif key == "Left" then
                    calpop.visible = false
                    curr_month = curr_month - 1
                    if curr_month == 0 then
                        curr_month = 12
                        curr_year = curr_year - 1
                    end
                    calpop.widget.date = {month = curr_month, year=curr_year}
                    calpop.visible = true
                elseif key == "Escape" then
                    calpop.visible = false
                    awful.keygrabber.stop(grabber)
                end
            end)
        end
    end)))

return M