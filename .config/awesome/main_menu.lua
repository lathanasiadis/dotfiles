local awful = require("awful")
-- Need to init beautiful to return a themed menu
local beautiful = require("beautiful")
beautiful.init("/home/aris/.config/awesome/theme.lua")

return awful.menu{
    {"Lock Screen", function () awful.spawn("lock-command", false) end},
    {"Sleep", function ()
        awful.spawn.with_shell("lock-command && systemctl suspend")
    end},
    {"Restart Awesome", awesome.restart},
    {"Quit Awesome", function () awesome.quit() end},
    {"Reboot", function () awful.spawn("systemctl reboot") end},
    {"Shutdown", function () awful.spawn("systemctl poweroff") end},
}
