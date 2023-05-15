---------------------------------------------------------------------------
---               File and filesystem related functionalities           ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--- @author m4sc2                                                       ---
---                                                                     ---
---                                                                     ---
---------------------------------------------------------------------------

local spawn  = require("awful.spawn")
local timer  = require("gears.timer")
local debug  = require("debug")
local io     = { lines = io.lines,
                 open  = io.open }

local _filesystem = {}


-- get first line of a file
function _filesystem.first_line(path)
    local file, first = io.open(path, "rb"), nil
    if file then
        first = file:read("*l")
        file:close()
    end
    return first
end

-- run a command and execute a function on its output line by line
function _filesystem.line_callback(cmd, callback)
    return spawn.with_line_callback(cmd, {
        stdout = function (line)
            callback(line)
        end,
    })
end

-- get a table with all lines from a file
function _filesystem.lines_from(path)
    local lines = {}
    for line in io.lines(path) do
        lines[#lines + 1] = line
    end
    return lines
end

function _filesystem.removeMultilines(str)
    local lines = str:gmatch("([^\r\n]+)\r?\n?")
    for line in lines do
        return line
    end    
end

return _filesystem