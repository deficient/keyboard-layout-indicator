## awesome.keyboard-layout-indicator

### Description

Keyboard layout indicator+switcher widget for awesome window manager.

### Installation

Drop the script into your awesome config folder. Suggestion:

```bash
cd ~/.config/awesome
git clone git@github.com:thomas-glaessle/awesome.keyboard-layout-indicator.git
ln -s awesome.keyboard-layout-indicator/keyboard-layout-indicator.lua
```


### Usage

In your `rc.lua`:

```lua
-- load the widget code
local layout_indicator = require("keyboard-layout-indicator")

-- define your layouts
kbdcfg = layout_indicator({
    layouts = {
        {name="dv",  layout="de",  variant="dvorak"},
        {name="de",  layout="de",  variant=nil},
        {name="us",  layout="us",  variant=nil}
    }
})

-- optionally add a middle-mouse binding to set a custom layout:
kbdcfg.widget:buttons(awful.util.table.join(
    kbdcfg.widget:buttons(),
    awful.button({ }, 2, 
        function ()
            awful.prompt.run(
                { prompt="Run: ", text="setxkbmap " },
                mypromptbox[mouse.screen].widget,
                function(cmd) kbdcfg:setcustom(cmd) end )
        end)
))

-- add the widget to your wibox
for s = 1, screen.count() do
  
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    ...
    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(kbdcfg.widget)
    ...

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
```


### Requirements

* [awesome 3.5](http://awesome.naquadah.org/)
