-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local ruled = require("ruled")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- My modules
local constants = require("constants")
local mymainmenu = require("main_menu")
local snotifs = require("status_notifications")
local sinkindicator = require("sink_indicator")
local bar_monitors = require("bar_monitors") 


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(constants.theme_path)
-- This is used later as the default terminal and editor to run.
terminal = "kitty --session fish"
editor = "vim" or os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
-- Default modkey.
modkey = "Mod4"
-- }}}

-- Start menu
-- Create a launcher widget and a main menu

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        -- awful.layout.suit.tile.left,
        -- awful.layout.suit.tile.bottom,
        -- awful.layout.suit.tile.top,
        -- awful.layout.suit.fair,
        -- awful.layout.suit.fair.horizontal,
        -- awful.layout.suit.spiral,
        -- awful.layout.suit.spiral.dwindle,
        -- awful.layout.suit.max,
        -- awful.layout.suit.max.fullscreen,
        -- awful.layout.suit.magnifier,
        -- awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
                image     = beautiful.wallpaper,
                horizontal_fit_policy = "fit",
                vertical_fit_policy   = "fit",
                widget    = wibox.widget.imagebox,
        }
    }
end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = require("clock")

local workspaces = {"1", "2", "", "", "", "", ""}
screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    -- Set preferred layout for each workspace
    local l = awful.layout.suit
    local layout = {l.floating, l.tile, l.tile, l.floating, l.tile, l.tile, l.tile}
    awful.tag(workspaces, s, layout)

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
        },
        widget_template = {
            {
                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    widget = wibox.container.place,
                },
                id = "background_role",
                forced_width = 40,
                widget = wibox.container.background
            },
            widget = wibox.container.margin,
            left = 5,
            right = 5,
        }
    }

    s.mytasklist_items = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
        },
        layout   = {
            layout  = wibox.layout.fixed.horizontal,
            spacing = 20,
            spacing_widget = {
                widget = wibox.container.place,
                halign = "center",
                valign = "center",
                {
                    widget = wibox.widget.separator,
                    shape = gears.shape.circle,
                    forced_width = 6,
                    color = constants.lavender,
                },
            },
        },
        widget_template = {
            layout = wibox.layout.align.vertical,
            {
                wibox.widget.base.make_widget(),
                widget = wibox.container.background,
                id = "background_role",
                -- opacity = 0.75,
                forced_height = 2
            },
            {
                awful.widget.clienticon,
                margins = 3,
                widget  = wibox.container.margin
            },
            -- nil,
        },
    }

    s.mytasklist = wibox.widget {
        widget = wibox.container.place,
        halign = "center",
        valign = "center",
        {
            widget = wibox.container.margin,
            margins = 3,
            s.mytasklist_items
        }
    }

    s.right_bar = {mykeyboardlayout, sinkindicator}
    for _, val in ipairs(bar_monitors) do
        table.insert(s.right_bar, val)
    end
    table.insert(s.right_bar, mytextclock)
    table.insert(s.right_bar, wibox.widget.systray())
    table.insert(s.right_bar, s.mylayoutbox)

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen   = s,
        border_color = constants.blue,
        border_width = 2, 
        margins = 9,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
                s.mytaglist,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = 5,
                table.unpack(s.right_bar),
            },
        }
    }
end)

-- }}}

-- Mouse bindings
-- Right click shows start menu
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
})

-- Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey },            "r",     function () os.execute("rofi -show combi") end,
              {description = "rofi", group = "launcher"}),
})

-- Screenshots
awful.keyboard.append_global_keybindings({
    awful.key({ }, "Print", function () awful.spawn("flameshot gui") end,
        {description = "screenshot (interactive)", group = "screen"}),
    awful.key({ modkey, }, "Print", function () awful.spawn("flameshot full -p /home/aris/Pictures/Screenshots/") end,
        {description = "screenshot (auto save full screen)", group = "screen"}),
    awful.key({ modkey,}, "z", function () awful.spawn("/home/aris/Documents/bdocr/bdocr.sh") end,
    {description = "OCR a screenshot selection", group = "screen"}),
}) 

-- Volume/Brightness Control
awful.keyboard.append_global_keybindings({
    awful.key({}, "XF86AudioLowerVolume",
        function ()
            snotifs.notif.volume("dec")
        end
    ),
    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            snotifs.notif.volume("inc")
        end
    ),
    awful.key({}, "XF86AudioMute",
        function ()
            snotifs.notif.volume("mute")
        end
    ),
    awful.key({}, "XF86MonBrightnessUp",
        function ()
            awful.spawn("", false)
            snotifs.notif.brightness()
        end
    ),
    awful.key({}, "XF86MonBrightnessDown",
        function ()
            awful.spawn("xbacklight -dec 10 -time 1 -steps 1", false)
            snotifs.notif.brightness()
        end
    )
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:activate { raise = true, context = "key.unminimize" }
                  end
              end,
              {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "v", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "v", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
})


awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

-- }}}

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }
    -- Specific client rules
    ruled.client.append_rule{
        id = "nemo_pos",
        rule = { class = "Nemo" },
        properties = {
            height = 700,
            width = 1200,
            placement = awful.placement.centered
        }
    }
    ruled.client.append_rule{
        id = "gimp_save_pos",
        rule = {
            class = "Gimp-3.0",
            name = "Save Image",
        },
        properties = {
            height = 700,
            width = 1200,
            placement = awful.placement.centered
        }
    }

    -- Default workspaces/tags
    ruled.client.append_rules {
        { rule = { class = "Logseq" },
          properties = { tag = workspaces[3] } },
        { rule = { class = "Hydrus Client" },
          properties = { tag = workspaces[4] } },
        { rule = { name = "Tauon" },
          properties = { tag = workspaces[5] } },
        { rule = { class = "Spotube" },
          properties = { tag = workspaces[5] } },
        { rule = { class = "net.thunderbird.Thunderbird" },
          properties = { tag = workspaces[6] } },
        { rule = { class = "qBittorrent" },
          properties = { tag = workspaces[7] } },
    }
end)

-- Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen = awful.screen.preferred,
            position = "bottom_right",
            implicit_timeout = constants.notif_timeout,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    local widget_template = nil
    -- Special notif template for volume/brightness notifs
    if n.app_name == constants.snotif_app_name then
        widget_template = snotifs.template
    end

    if n.title ~= nil then
        n.title = "<b>" .. n.title .. "</b>"
    end

    naughty.layout.box {
        notification = n,
        widget_template = widget_template
    }
end)

-- Run programs on startup
awful.spawn("pactl set-default-sink " .. constants.sinks.speakers, false)
awful.spawn.with_shell("/home/aris/.config/awesome/autorun.sh")