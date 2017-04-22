-- Keyboard Layout Switcher
-- Keyboard map indicator and changer

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local timer = gears.timer or timer

------------------------------------------
-- Private utility functions
------------------------------------------

local function trim(s)
    if s == nil then return nil end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function findindex(array, match)
    for k, v in pairs(array) do
        if match(v) then return k end
    end
end

local function readall(file)
    local text = file:read('*all')
    file:close()
    return text
end

local function readcommand(command)
    return readall(io.popen(command))
end


------------------------------------------
-- Indicator class
------------------------------------------

local indicator = {}

function indicator:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function indicator:init(args)
    self.cmd = "setxkbmap"
    self.layouts = args.layouts
    self.prompt = args.prompt or "Run: "
    self.preset = args.preset or self.cmd .. " "

    self.index = 1     -- 1-based index!
    self.current = nil

    self.widget = wibox.widget.textbox()
    self.widget.set_align("right")

    self.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() self:next() end),
        awful.button({ }, 3, function() self:prev() end),
        awful.button({ }, 4, function() self:prev() end),
        awful.button({ }, 5, function() self:next() end),
        -- execute prompt on middle click:
        awful.button({ }, 2, function ()
            awful.prompt.run {
                prompt       = self.prompt,
                text         = self.preset,
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = function(cmd) self:setcustom(cmd) end,
            }
        end)
    ))

    self.timer = timer({ timeout = args.timeout or 0.5 })
    self.timer:connect_signal("timeout", function() self:get() end)
    self.timer:start()
    self:get()
    return self
end

function indicator:set(i)
    -- set current index
    self.index = ((i-1)+#(self.layouts)) % #(self.layouts) + 1
    self.current = self.layouts[self.index]
    self:update()
    -- execute command
    local cmd = self.current.command
    if not self.current.command then
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
        markup = '<span color="' .. self.current.color .. '">' .. text ..'</span>'
        self.widget:set_markup(markup)
    else
        self.widget:set_text(text)
    end
end

function indicator:get()
    -- parse current layout from setxkbmap
    local status = readcommand(self.cmd .. " -query")
    local layout = trim(string.match(status, "layout:([^\n]*)"))
    local variant = trim(string.match(status, "variant:([^\n]*)"))
    -- find layout in self.layouts
    local index = findindex(self.layouts, function (v)
        return v.layout == layout and v.variant == variant
    end)
    if index then
        self.index = tonumber(index)
        self.current = self.layouts[index]
    else
        self.current = {color="yellow"}
        if variant then
            self.current.name = layout.."/"..variant
        else
            self.current.name = layout
        end
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

return setmetatable(indicator, {
    __call = indicator.new,
})

