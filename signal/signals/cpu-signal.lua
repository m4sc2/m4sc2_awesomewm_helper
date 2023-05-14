---------------------------------------------------------------------------
---                     CPU Information Signals                         ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--- @author: m4sc2                                                      ---
---                                                                     ---
---  Provides and Handles Signals related to CPU:                       ---
---   * broker::cpu - signal_emit   - provides current cpu load         ---
---                                                                     ---
---------------------------------------------------------------------------
--- usage: require('helpers.signal.signals.cpu-signal')                 ---
---                                                                     ---
---------------------------------------------------------------------------

local awful = require("awful")
local spawn = require("awful.spawn")

local cpu = {cpu_value = 0}

local function LIST_CPU_LOAD() return [[sh -c "vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'"]] end

local function worker(user_args)
    args = user_args or {}
    local timeout = 5
    
    function update()
        spawn.easy_async(LIST_CPU_LOAD(), function(stdout) extract_load_data(stdout) end)
        return cpu
    end

    function extract_load_data(stdout) 
        local cpu_idle = stdout
		local cpu_value = tonumber(100 - cpu_idle)
        cpu.cpu_value = cpu_value
    end

    broker.register_timed_signal("broker::cpu", update, timeout)

    return cpu
end

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })