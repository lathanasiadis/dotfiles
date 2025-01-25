local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local constants = require("constants")
local monitor = require("monitors").widget

local THRES_1 = 60 -- after this, the bar monitor turns yellow
local THRES_2 = 80 -- after this, the bar monitor turns red

local CPU_USE_ICON = ""
local TEMP_LOW_ICON = ""
local TEMP_MID_ICON = ""
local TEMP_HIGH_ICON = ""
local MEM_USE_ICON = ""
local BAT_LOW_ICON = ""
local BAT_MID_ICON = ""
local BAT_HIGH_ICON = ""

-- Remove the leading '+'; ignore the decimal part
local CPU_TEMP_CMD = "sensors | grep Package | awk '{print $4}' | cut -c 2- | cut -d'.' -f 1"

-- Idle CPU use: the mpstat line where the 13th column includes only numbers and dots;
-- return 100 - idle cpu use, ignore decimal part
local CPU_USE_CMD = "mpstat | awk '$13 ~ /[0-9.]+/ {print 100 - $13}' | cut -d'.' -f 1"

-- divide total mem by used
local MEM_USE_CMD = "free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d'.' -f 1"

local BAT_FILE = "/sys/class/power_supply/BAT1/capacity"
local BAT_CMD = "cat " .. BAT_FILE

local function widget_function(unit, compare_op, thresholds, icons)
    return function (widget, stdout)
        local stat = tonumber(stdout)
        local template = "<span foreground=\"%s\"><b>%s %d%s</b></span>"
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
        widget.font = constants.iconfont
        widget.markup = template:format(color, icon, stat, unit)
    end
end

local function less_op(x, y)
    return x < y
end

local function gt_op(x, y)
    return x>= y
end

local cpu_temp = monitor(CPU_TEMP_CMD, 5, "°C",
    less_op, {THRES_1, THRES_2}, {TEMP_LOW_ICON, TEMP_MID_ICON, TEMP_HIGH_ICON})
local cpu_use = monitor(CPU_USE_CMD, 10, "%",
    less_op, {THRES_1, THRES_2}, {CPU_USE_ICON, CPU_USE_ICON, CPU_USE_ICON})
local mem = monitor(MEM_USE_CMD, 10, "%",
    less_op, {THRES_1, THRES_2}, {MEM_USE_ICON, MEM_USE_ICON, MEM_USE_ICON})

local ret = {cpu_temp, cpu_use, mem}

local has_bat = nil
local bat_monitor = nil
-- This io call is blocking, but it only happens on startup, so it's ok
local f = io.open(BAT_FILE, "r")
if f ~= nil then
    io.close(f)
    has_bat = true
else
    has_bat = false
end

if has_bat then
    table.insert(ret, monitor(BAT_CMD, 10, "%",
        gt_op, {40, 20}, {BAT_HIGH_ICON, BAT_MID_ICON, BAT_LOW_ICON}))
end

return ret