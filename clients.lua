---------------------------------------------------------------------------
---                    Helper for Client Handling                       ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---                                                                     ---
---                                                                     ---
---                                                                     ---
---------------------------------------------------------------------------

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local helpers = {}

-- Maximizes client and also respects gaps
function helpers.maximize(c)
    c.maximized = not c.maximized
    if c.maximized then
        awful.placement.maximize(c, {
            honor_padding = true,
            honor_workarea = true,
            margins = beautiful.useless_gap * 2
        })

    end
    c:raise()
end

-- Maximizes client and also respects gaps
function helpers.maximize_margins(c)
    if c.maximized then
        awful.placement.maximize(c, {
            honor_padding = true,
            honor_workarea = true,
            margins = beautiful.useless_gap * 2
        })

    end
    c:raise()
end

return helpers