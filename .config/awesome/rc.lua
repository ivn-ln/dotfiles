-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
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
-- Cycle focus
local cyclefocus = require('cyclefocus')
local xresources = require("beautiful.xresources")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Naughty config
naughty.config.padding = 10
naughty.config.spacing = 5
naughty.config.icon_dirs = {"/home/illarn/Catppuccin-Mocha-Alt2/"}
naughty.config.icon_format = {"svg"} 
naughty.config.defaults.shape = function(cr, w, h) 
    gears.shape.rounded_rect(cr, w, h, xresources.apply_dpi(8))
end 

function naughty.config.notify_callback(args)
    awful.spawn.with_shell("play ~/Audio/confirmation_001.ogg gain -15") 
    return args
end

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
beautiful.init("/home/illarn/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty" 
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    --awful.layout.suit.floating,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.tile,
    awful.layout.suit.fair,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.max.fullscreen,
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

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


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
    awful.tag({ "1", "2", "3", "4", "5", " ", " ", " ", "  " }, s, awful.layout.layouts[1])

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
   -- s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
   -- s.mywibox:setup {
   --     layout = wibox.layout.align.horizontal,
   --     { -- Left widgets
    --        layout = wibox.layout.fixed.horizontal,
    --        s.mytaglist,
    --        
    --    },
--	nil,
  --      --s.mytasklist, -- Middle widget
    --    { -- Right widgets
      --      layout = wibox.layout.fixed.horizontal,
        --    wibox.widget.systray(),
	--    mykeyboardlayout,
        --    mytextclock,
        --    s.mylayoutbox,
      --  },
   -- }
end)
-- }}}

-- {{{ Mouse bindings
--root.buttons(gears.table.join(
--    awful.button({ }, 3, function () mymainmenu:toggle() end),
--    awful.button({ }, 4, awful.tag.viewnext),
--    awful.button({ }, 5, awful.tag.viewprev)
--))
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
   -- awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
   --           {description = "show main menu", group = "awesome"}),

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
    awful.key({ modkey,           }, "`",
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
    awful.key({ modkey,          }, "r", function ()
	    local screen = awful.screen.focused()
		local tag = screen.tags[6]
        if tag then
            tag:view_only()
        end
    end,
    {description = "switch to terminal", group = "tag"}),
    awful.key({modkey, "Shift"}, "q", function () awful.spawn.with_shell("lxsession-logout") end,
    {description = "logout window", group = "launcher"}),
    awful.key({modkey, }, "e", function () awful.spawn.with_shell("thunar") end,
    {description = "open file explorer", group = "launcher"}),
    awful.key({modkey, }, "b", function ()
	    --awful.spawn.with_shell("xdg-open https://")
		local screen = awful.screen.focused()
		local tag = screen.tags[7]
                        if tag then
                           tag:view_only()
                        end
    end,
    	     {description = "open browser", group = "launcher"}),
    awful.key({modkey, }, "q", function ()
        awful.spawn.with_shell("rofi -show drun")
    end,
    {description = "run a program", group = "launcher"}),
    awful.key({ modkey,           }, "t",      function ()
	    local screen = awful.screen.focused()
		local tag = screen.tags[8]
			if tag then
                tag:view_only()
            end
    end,
    {description = "switch to telegram desktop", group = "launcher"}),
    awful.key({modkey, }, "c", function()
        local screen = awful.screen.focused()
            local tag = screen.tags[9]
            if tag then
                tag:view_only()
            end
	end,
	{description = "switch to vscode desktop", group = "launcher"}),
    awful.key({modkey}, "a",  function ()        
        awful.spawn.with_shell("/usr/share/.scripts/dim-screen.sh")
    end,
    {description = "Lock screen", group="misc"}),
    awful.key({ modkey, "Control", "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
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
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "w",
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

    -- Prompt
    --awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --              {description = "run prompt", group = "launcher"}),

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
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --          {description = "show the menubar", group = "launcher"})
    awful.key({ modkey, "Shift"}, "s", function () 
        awful.spawn.with_shell("flameshot gui")
    end,
    {description = "screenshot", group = "client"})
)

clientkeys = gears.table.join(
cyclefocus.key({modkey, }, "Tab", {
cycle_filters = { cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
    keys = {'Tab', 'ISO_Left_Tab'}, show_clients = false, display_notifications=false, raise_clients = false
    }),
	awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "w",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
       awful.key({ modkey,           }, "w",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({modkey, "Shift"}, "Tab",  function ()
	local c = awful.client.focus.history.list[2]
	awful.client.cycle(true)
	--awful.client.swap.byidx(1, c) 
	--client.focus = c
	--local t = client.focus and client.focus.first_tag or nil
	--if t then
	--	t:view_only()
	--end
        end, {description = "cycle windows placement", group = "client"}),
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
        awful.key({ modkey, "Control" }, "r",
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[6]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle terminal tag", group = "tag"}),
        awful.key({ modkey, "Control" }, "b",
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[7]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle browser tag", group = "tag"}),
        awful.key({ modkey, "Control" }, "c",
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[9]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle code tag", group = "tag"}),
        awful.key({ modkey, "Control" }, "t",
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[8]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle telegram tag", group = "tag"}),
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
          "veromix",
          "xtightvncviewer",
          "Pavucontrol",
          },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true, ontop = true, placement = awful.placement.centered }},
      {rule_any = {
        class = {
            "Blueman-manager",
            "Pavucontrol"
        }
      },
      properties = {placement = awful.placement.top_right, border_width = 0, immobilized = true}},
      {rule_any = {
        class = {
            "com.github.calo001.luna"
        },
	name = {
		"com.github.calo001.luna"
	}
      },
      properties = {floating = true, ontop = true, placement = awful.placement.top, border_width = 0, immobilized = true, width = 1200, height = 1000}},
      {rule_any = {
        class = {
            "Polybar"
        }
      },
      properties = {focusable = false, border_width = 0, tag = " "}},
      {
        rule_any = {
            class = {
                "mirage"
            },
            properties = {ontop = true}
      }},
      {
        rule_any = {
            name = {
                "Picture-in-Picture"
            },
            role = {
                "PictureInPicture"
        }},
        properties = {sticky = true, border_width = 0, floating = true, ontop = true, dockable = false}
      },

    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    --}, properties = { titlebars_enabled = true }
    --},

    -- Set Firefox to always map on the tag named "2" on screen 1.
     { rule = { class = "floorp" },
       properties = { screen = 1, tag = " " } },
     {rule = {class = "Telegram" },
      properties = {screen = 1, tag = " "}},
     {rule = {class = "Code"},
     properties = {screen = 1, tag = "  "}},
     { rule = { class = "kitty" },
     properties = {screen = 1, tag = " "}},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
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

client.connect_signal("unfocus", function (c)
    if c.class == "Blueman-manager" or c.class == "Pavucontrol" or c.class == "com.github.calo001.luna" then
        c:kill()
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autostart
awful.spawn.easy_async("pgrep picom -a", function(stdout)
    if not string.find(stdout, "picom") then
        awful.spawn.with_shell("picom -b --experimental-backends")
    end
end)
awful.spawn.easy_async("pgrep nitrogen -a", function(stdout)
    if not string.find(stdout, "nitrogen") then
        awful.spawn.with_shell("nitrogen --set-zoom-fill --random ~/Wallpaper/ --save")
    end
end)
awful.spawn.easy_async("pgrep kitty -a", function(stdout)
    if not string.find(stdout, "kitty") then
        awful.spawn.with_shell("kitty")
    end
end)
awful.spawn.easy_async("pgrep polybar -a", function(stdout)
    if not string.find(stdout, "polybar") then
        awful.spawn.with_shell("polybar")
    end
end)
awful.spawn.easy_async("pgrep telegram -a", function(stdout)
    if not string.find(stdout, "telegram") then
        awful.spawn.with_shell("flatpak run org.telegram.desktop")
    end
end)
awful.spawn.easy_async("pgrep floorp -a", function(stdout)
    if not string.find(stdout, "floorp") then
        awful.spawn.with_shell("flatpak run one.ablaze.floorp")
    end
end)
awful.spawn.with_shell("xset s 300")
awful.spawn.with_shell("xinput set-prop 14 325 1")
awful.spawn.with_shell("xinput set-prop 14 302 1")
awful.spawn.with_shell("xinput set-prop 14 311 1")
awful.spawn.with_shell("sleep 1.0s && xss-lock -n /usr/share/.scripts/dim-screen.sh xlock")
awful.spawn.with_shell("chmod a+wr ~/brightness.sh")
awful.spawn.with_shell("sh ~/brightness.sh")
awful.spawn.with_shell("bt-adapter --adapter=illarn --set Pairable 1")
awful.spawn.with_shell("bt-adapter --adapter=illarn --set Powered 1")
naughty.notify({title = "AwesomeWM", text = "Reloaded successfully"})

