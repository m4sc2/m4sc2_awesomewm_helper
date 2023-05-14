local beautiful = require "beautiful"
local gears = require "gears"
local wibox = require "wibox"
local dpi = beautiful.xresources.apply_dpi

local helpers = {}


function helpers.deco(widget, user_args)
    local args = user_args or {}
    left_border = args.left_border or 10
    right_border = args.right_border or 10
    top_border = args.top_border or 3
    bottom_border = args.bottom_border or 3
    local deco = wibox.widget {
        {
            widget,
            left   = left_border,
            right  = right_border,
            top    = top_border,
            bottom = bottom_border,                
            widget = wibox.container.margin
        },       
        bg = beautiful.bg_normal,
        shape = gears.shape.rounded_bar,
        border_width = dpi(1),
        border_color =  beautiful.bg_focus,
        widget = wibox.container.background,
    }

return deco

end

function helpers.deco_no_margin(widget)
    local deco = wibox.widget {
        {
            widget,
            left   = 1,
            right  = 0,
            top    = 1,
            bottom = 1,                
            widget = wibox.container.margin
        },       
        bg = beautiful.bg_normal,
        shape = gears.shape.rounded_bar,
        border_width = dpi(0),
        border_color =  beautiful.bg_focus,
        widget = wibox.container.background,
    }

return deco

end

return helpers