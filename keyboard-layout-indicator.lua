-- Keyboard Layout Switcher
-- Keyboard map indicator and changer

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local timer = gears.timer or timer
local spawn = awful.spawn


------------------------------------------
-- Compatibility with Lua <= 5.1
------------------------------------------

local _unpack = table.unpack or unpack

-- same as table.pack in lua 5.2:
local function pack(...)
    return {n = select('#', ...), ...}
end

-- different from table.unpack in lua.5.2:
local function unpack(t)
    return _unpack(t, 1, t.n)
end


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

local function spawn_sequential(...)
    if select('#', ...) > 0 then
        local command = select(1, ...)
        local args = pack(select(2, ...))
        local exec_tail = function()
            spawn_sequential(unpack(args))
        end
        if type(command) == "function" then
            command()
            exec_tail()
        elseif command == nil then
            exec_tail()
        else
            spawn.easy_async(command, exec_tail)
        end
    end
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
    self.post_set_hooks = args.post_set_hooks or {"xmodmap ~/.Xmodmap"}

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

    awesome.connect_signal("xkb::map_changed", function() self:update() end)
    awesome.connect_signal("xkb::group_changed", function() self:update() end)

    self.timer = timer({ timeout = args.timeout or 0.5 })
    self.timer:connect_signal("timeout", function() self:update() end)
    self.timer:start()
    self:update()
    return self
end

function indicator:set(i)
    -- set current index
    self.index = (i-1) % #(self.layouts) + 1
    self.current = self.layouts[self.index]
    self:update_text()
    -- execute command
    local command = self.current.command or ("%s %s %s"):format(
        self.cmd, self.current.layout, self.current.variant or "")
    spawn_sequential(command, unpack(self.post_set_hooks))
end

function indicator:setcustom(str)
    spawn.easy_async(str, function()
        self:update()
    end)
end

function indicator:update()
    self:get_async(function(index, info)
        self.known = index ~= nil
        self.index = index or self.index
        self.current = info
        self:update_text()
    end)
end

function indicator:update_text()
    self.widget:set_markup(("<span %s>%s</span>"):format(
        self.current.attr or "", self.current.name))
end

function indicator:get_async(callback)
    spawn.easy_async(self.cmd .. " -query", function(status)
        callback(self:parse_status(status))
    end)
end

function indicator:parse_status(status)
    -- parse current layout from setxkbmap
    local layout = trim(string.match(status, "layout:([^\n]*)"))
    local variant = trim(string.match(status, "variant:([^\n]*)"))
    -- find layout in self.layouts
    local index = findindex(self.layouts, function (v)
        return v.layout == layout and v.variant == variant
    end)
    return index, index and self.layouts[tonumber(index)] or {
        attr    = 'color="yellow"',
        layout  = layout,
        variant = variant,
        name    = variant and layout.."/"..variant or layout,
    }
end

function indicator:next()
    self:set(self.index + (self.known and 1 or 0))
end

function indicator:prev()
    self:set(self.index - (self.known and 1 or 0))
end

return setmetatable(indicator, {
    __call = indicator.new,
})

