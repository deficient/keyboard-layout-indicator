## awesome.keyboard-layout-indicator

### Description

Keyboard layout indicator+switcher widget for awesome window manager.

### Installation

Drop the script into your awesome config folder. Suggestion:

```bash
cd ~/.config/awesome
git clone https://github.com/deficient/keyboard-layout-indicator.git
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

NOTE: middle click on the widget executes a prompt which lets you set a custom
keyboard layout. However, this will work only if you assign `s.mypromptbox` as
in the awesome 4.0 default `rc.lua`. Otherwise, you have to rebind the
behaviour manually, see the source code.


### Requirements

* [awesome 4.0](http://awesome.naquadah.org/) or possibly 3.5
