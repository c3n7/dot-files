-- vim:foldmethod=marker
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library {{{
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- }}}

-- Widgets {{{
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
-- local mpd_widget = require("awesome-wm-widgets.mpdarc-widget.mpdarc")
local volumearc_widget = require("awesome-wm-widgets.volumearc-widget.volumearc")
local github_contributions_widget = require("awesome-wm-widgets.github-contributions-widget.github-contributions-widget")
local fs_widget = require("awesome-wm-widgets.fs-widget.fs-widget")
-- }}}

-- custom utility script --
local mpd_util = require("c3n7ly-utilities.mpd.mpd")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.magnifier,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

sysmenu = {
    { "reboot", "shutdown -r reboot" },
    { "shutdown", "shutdown now" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal },
                                    { "sys", sysmenu }
                                  }
                        })

praisewidget = wibox.widget.textbox()
praisewidget.text = "c3n7"
separator = wibox.widget.separator({
    forced_width = 10,
    color = beautiful.bg_normal,
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    local l = awful.layout.suit
    local layouts = {l.tile, l.tile, l.tile, l.tile, l.tile, l.tile, l.tile, l.tile, l.corner.nw}
    -- awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            praisewidget,
            s.mytaglist,
            s.mypromptbox,
        },
        { -- Middle widget
            layout = wibox.layout.fixed.horizontal,
            s.mytasklist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- mpd_widget,
            -- mykeyboardlayout,
            separator,
            github_contributions_widget({
                username="c3n7",
                theme="standard",
                color_of_empty_cells = beautiful.bg_normal,
                days=600,
            }),
            separator,
            cpu_widget(),
            ram_widget(),
            separator,
            volumearc_widget(),
            separator,
            batteryarc_widget({
                show_current_level = true,
            }),
            separator,
            mytextclock,
            fs_widget(),
            wibox.widget.systray(),
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r",
        function ()
            -- Also reload .Xresources with this script
            awful.spawn.with_shell("/home/timo/.config/dot-files/color-generator/src/main.py")
            awesome.restart()
        end,
      {description = "reload awesome", group = "awesome"}),
    -- awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              -- {description = "quit awesome", group = "awesome"}),

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
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Dmenu
    awful.key({ modkey },            "d",     function () 
        awful.util.spawn(
        string.format(
            "dmenu_recency -nf '%s' -nb '%s' -sb '%s' -sf '%s' -fn 'monospace-9' -p 'run:'",
            beautiful.fg_focus, beautiful.bg_normal, beautiful.border_focus, beautiful.fg_normal)
        )
    end,
            {description = "run dmenu", group = "launcher"}),


    awful.key({ modkey, "Shift" },            "y",     function () 
        os.execute(
            string.format(
                "YTFZF_EXTMENU=\"dmenu -i -l 30 -p %s:\" ytfzf -D",
                -- "YTFZF_EXTMENU=\"dmenu -i -l 30 -nf '%s' -nb '%s' -sb '%s' -sf '%s' -p search:\" ytfzf -D",
                -- beautiful.fg_focus, beautiful.bg_normal, beautiful.border_focus, beautiful.fg_normal
                "ytfzf"
            )
        )
    end,
            {description = "play from youtube", group = "launcher"}),



    -- Applications launcher
    awful.key({ modkey, "Shift" },            "i",     function () 
        awful.util.spawn("/home/timo/.config/rofi/launchers-git/launcherAlt.sh")
    end,
              {description = "applications menu", group = "launcher"}),


    -- Switch Graphics
    awful.key({ modkey, "Control" }, "g",     function () 
        awful.util.spawn("/home/timo/.config/dmenu_scripts/switch_graphics.sh")
    end,
              {description = "switch graphics card", group = "display"}),


    -- Brightness Controls --
    awful.key({}, "XF86MonBrightnessUp",     function () 
        awful.util.spawn("light -A 2")
        awful.util.spawn("notify-send 'brightness up'")
    end,
              {description = "brightness up", group = "display"}),


    awful.key({}, "XF86MonBrightnessDown",     function () 
        awful.util.spawn("light -U 2")
        awful.util.spawn("notify-send 'brightness down'")
    end,
              {description = "brightness down", group = "display"}),


    -- Audio Controls --
    awful.key({}, "XF86AudioMute",     function () 
        awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    end,
              {description = "mute speaker", group = "sound"}),

    awful.key({}, "XF86AudioMicMute",     function () 
        awful.util.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    end,
              {description = "mute mic", group = "sound"}),


    awful.key({}, "XF86AudioRaiseVolume",     function () 
        awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ false")
        awful.util.spawn("pactl set-sink-volume 0 +5%")
    end,
              {description = "volume up", group = "sound"}),

    awful.key({}, "XF86AudioLowerVolume",     function () 
        awful.util.spawn("pactl set-sink-mute @DEFAULT_SINK@ false")
        awful.util.spawn("pactl set-sink-volume 0 -5%")
    end,
              {description = "volume down", group = "sound"}),


    -- MPD Controls
    awful.key({}, "XF86AudioPlay",     function () 
        awful.util.spawn("mpc toggle")

        mpd_util.update_stats()
        naughty.notify({ title = mpd_util.mpd_status(),
            text = mpd_util.current_track(),
            timeout = 3
        })
    end,
              {description = "play/pause", group = "music"}),

    awful.key({}, "XF86AudioNext",     function () 
        awful.util.spawn("mpc next")


        mpd_util.update_stats()
        naughty.notify({ title = mpd_util.mpd_status(),
            text = mpd_util.current_track(),
            timeout = 3
        })
    end,
              {description = "next", group = "music"}),

    awful.key({}, "XF86AudioPrev",     function () 
        awful.util.spawn("mpc prev")

        mpd_util.update_stats()
        naughty.notify({ title = mpd_util.mpd_status(),
            text = mpd_util.current_track(),
            timeout = 3
        })
    end,
              {description = "prev", group = "music"}),


    -- Screenshots
    awful.key({modkey}, "Print",     function () 
            awful.util.spawn_with_shell("scrot --focused -q 100 -e 'mv $f /home/timo/Pictures/'")
            naughty.notify({ title = "Window screenshot saved",
                text = "Screenshot saved in ~/Pictures",
                timeout = 5
            })
    end,
              {description = "focused window screenshot", group = "display"}),

    awful.key({modkey, "Shift"}, "Print",     function () 
            awful.util.spawn_with_shell("scrot --select -q 100 -e 'mv $f /home/timo/Pictures/'")
            naughty.notify({ title = "Select area to screenshot",
                text = "Screenshot will be saved in ~/Pictures",
                timeout = 5
            })
    end,
              {description = "draw screenshot area", group = "display"}),


    awful.key({}, "Print",     function () 
            awful.util.spawn_with_shell("scrot -q 100 -e 'mv $f /home/timo/Pictures/'")
            naughty.notify({ title = "Screenshot saved",
                text = "Screenshot saved in ~/Pictures",
                timeout = 5
            })
    end,
              {description = "fullscreen screenshot", group = "display"}),


    -- Applications
    awful.key({modkey}, "F2",     function () 
        awful.util.spawn("brave")
    end,
              {description = "brave browser", group = "applications"}),


    awful.key({modkey}, "F3",     function () 
        awful.util.spawn("pcmanfm")
    end,
              {description = "pcmanfm", group = "applications"}),



    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),

    awful.key({modkey, 'Control'}, "l",     function () 
        awful.util.spawn("i3lock-fancy")
    end,
              {description = "lock screen", group = "awesome"}),


    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
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
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "com-badlogic-gdx-setup-GdxSetup",
          "veromix",
          "Pavucontrol",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
          "Android Emulator - Pixel_4_API_30:5554"
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    -- { rule_any = {type = { "normal", "dialog" }
      -- }, properties = { titlebars_enabled = true }
    -- },

    {
        rule = { 
          name = "Android Emulator - Pixel_4_API_30:5554"
        },
        properties = {
            floating = true,
            width = 407,
            height = 864,
            x  = 1230,
            y = 86
        }
    },


    -- Set Libreoffice to always be tiled
    { rule = { class = "libreoffice" },
      properties = { maximized = false }
    },

    -- Set Brave Browser to always be tiled
    { rule = { class = "Brave-browser" },
      properties = { maximized = false, floating = false }
    },

    -- Set Unity to always be maximized
    { rule = { class = "Unity" },
      properties = { maximized = true }
    },


    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Rounded borders for clients
    -- https://www.reddit.com/r/awesomewm/comments/61s020/round_corners_for_every_client/
    c.shape = function(cr,w,h)
        gears.shape.rounded_rect(cr,w,h,6)
    end

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)


-- Toggle floating only for the floating windows
-- client.connect_signal("property::floating", function(c)
    -- if c.floating then
        -- awful.titlebar.show(c)
    -- else
        -- awful.titlebar.hide(c)
    -- end
-- end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
    -- c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- AutoStart these {{{
awful.spawn.with_shell("mpd")
-- awful.spawn.with_shell("nitrogen --restore")
awful.spawn.with_shell("wal --R")
awful.spawn.with_shell("picom")
awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
awful.spawn.with_shell("nm-applet")
awful.spawn.with_shell("xfce4-power-manager")
awful.spawn.with_shell("pamac-tray")
-- awful.spawn.with_shell("clipit")
awful.spawn.with_shell("fix_xcursor")
awful.spawn.with_shell("/home/timo/.config/conky/launch.sh")
-- }}}

beautiful.useless_gap = 4
