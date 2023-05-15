---------------------------------------------------------------------------
---                    simple button creation helper                    ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--- Credits:                                                            ---
---     streetturtle - original created                                 ---
---                  - https://github.com/streetturtle/awesome-buttons  ---
---------------------------------------------------------------------------
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local buttons = {}

buttons.with_icon_text = function(args)
    local type = args.type or 'basic'
    local color = args.color or beautiful.bg_focus
    local color_highlight = args.color2 or beautiful.fg_normal
    local text = args.text
    local shape = args.shape or 'circle'
    local onclick = args.onclick or function () end
    local height = args.height or 35
    local width = args.width or 35

    local result = wibox.widget{
        {
            {
                text = text,
                valign ='center',
                halign ='center',
                forced_height = height,
                forced_width = width,
                widget = wibox.widget.textbox,
            },
            --top = 10, bottom = 10, left = 8, right = 8,
            widget = wibox.container.margin,
        },
        bg = '#00000000',
        widget = wibox.container.background,
    }

    if type == 'outline' then
        result:set_shape_border_color(color)
        result:set_shape_border_width(3)
    elseif type == 'flat' then
        result:set_bg(color)
    end

    if shape == 'circle' then
        result:set_shape(function(cr, width, height) gears.shape.circle(cr,width,height) end)
    elseif shape == 'rounded_bar' then
        result:set_shape(gears.shape.rounded_bar)
    elseif shape == 'rounded_rect' then
        result:set_shape(function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 4) end)
    else
        result:set_shape(gears.shape.rectangle)
    end

    local old_cursor, old_wibox
    result:connect_signal("mouse::enter", function(c)
        if type ~= 'flat' then
            c:set_shape_border_color(color_highlight)
        end
        pcall(function()
                local wb = mouse.current_wibox
                old_cursor, old_wibox = wb.cursor, wb
                wb.cursor = "hand1"
        end)
    end)
    result:connect_signal("mouse::leave", function(c)
        if type ~= 'flat' then
            c:set_shape_border_color(color)
        end
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    result:connect_signal("button::press", function() onclick() end)

    return result
end

return buttons
