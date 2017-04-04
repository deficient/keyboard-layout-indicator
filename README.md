## awesome.keyboard-layout-indicator

### Description

Keyboard layout indicator+switcher widget for awesome window manager.

### Installation

Drop the script into your awesome config folder. Suggestion:

```bash
cd ~/.config/awesome
git clone git@github.com:thomas-glaessle/awesome.keyboard-layout-indicator.git keyboard-layout-indicator
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
    ...
    right_layout:add(kbdcfg.widget)
    ...


-- Add bindings
local globalkeys = awful.util.table.join(
    ...
    awful.key({ "Shift"         }, "Shift_R", function() kbdcfg:next() end ),
    awful.key({ "Mod4", "Shift" }, "Shift_R", function() kbdcfg:prev() end ),
    ...
)
```


### Requirements

* [awesome 4.0](http://awesome.naquadah.org/) or possibly 3.5
