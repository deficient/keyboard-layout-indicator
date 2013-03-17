local awful = require("awful")
local wibox = require("wibox")

-- Keyboard Layout Switcher
-- Keyboard map indicator and changer
local indicator = { mt = {}, wmt = {} }
indicator.wmt.__index = indicator

function indicator.new(args)
    local sw = setmetatable({}, indicator.wmt)

    sw.cmd = "setxkbmap"
    sw.layouts = args.layouts

    sw.index = 1     -- 1-based index!
    sw.current = nil

    sw.widget = wibox.widget.textbox()
    sw.widget.set_align("right")

    sw.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() sw:next() end),
        awful.button({ }, 3, function() sw:prev() end),
        awful.button({ }, 4, function() sw:prev() end),
        awful.button({ }, 5, function() sw:next() end)
    ))

    sw.timer = timer({ timeout = args.timeout or 10 })
    sw.timer:connect_signal("timeout", function() sw:get() end)
    sw.timer:start()
    sw:get()
    return sw
end

function indicator:set(i)
    -- set current index
    self.index = ((i-1)+#(self.layouts)) % #(self.layouts) + 1
    self.current = self.layouts[self.index]
    self:update()
    -- execute command
    local cmd
    if self.current.command then
        cmd = self.current.command
    else
        cmd = self.cmd .. " " .. self.current.layout
        if self.current.variant then
            cmd = cmd .. " " .. self.current.variant
        end
    end
    os.execute( cmd )

    os.execute("xmodmap ~/.Xmodmap")
end

function indicator:setcustom(str)
    os.execute(str)
    self:get()
end

function indicator:update()
    -- update widget text
    local text = self.current.name
    if self.current.color then
        text = fg(self.current.color, text)
    end
    self.widget:set_text(text)
end

function indicator:get(i)
    -- parse current layout from setxkbmap
    local status = readcommand(self.cmd .. " -query")
    local layout = trim(string.match(status, "layout:([^\n]*)"))
    local variant = trim(string.match(status, "variant:([^\n]*)"))
    -- find layout in self.layouts
    local index = findindex(self.layouts,
        function (v)
            return v.layout==layout and v.variant == variant
        end)
    if index == nil then
        self.current = {color="yellow"}
        if variant then
            self.current.name = layout.."/"..variant
        else
            self.current.name = layout
        end
    else
        self.index = tonumber(index)
        self.current = self.layouts[index]
    end
    -- update widget
    self:update()
end

function indicator:next()
    self:set(self.index + 1)
end

function indicator:prev()
    self:set(self.index - 1)
end

function indicator.mt:__call(...)
    return indicator.new(...)
end

return setmetatable(indicator, indicator.mt)

