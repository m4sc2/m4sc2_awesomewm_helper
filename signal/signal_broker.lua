---------------------------------------------------------------------------
---                    Signals Handler and Broker                       ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---                                                                     ---
--- eg. global handler load via rc.lua                                  ---
---                                                                     ---
---                                                                     ---
---------------------------------------------------------------------------
--- usage: broker = require('<...>.signal_broker')                      ---
---                                                                     ---
---------------------------------------------------------------------------
--- Credits:                                                            ---
---     raven2cz - idea provider and original created                   ---
---              - https://github.com/raven2cz/awesomewm-config/        ---
---------------------------------------------------------------------------

-- import for creation of time emited signals
local timer = require("gears.timer")

local signalBroker = {}
-- holds all registered signals and including callback functions
if _registeredSignals == nil then
    _registeredSignals = {}
end

-- holds the last emited value for an signal
if _lastSignalResults == nil then
    _lastSignalResults = {}
end

local function get_or_register_signal(name)
    if not _registeredSignals[name] then
        assert(type(name) == "string", "name must be a string, got: " .. type(name))
        _registeredSignals[name] = {
            registeredFunctions = {}
        }
    end
    return _registeredSignals[name]
end

--- Provides last callback value for a signal.
function signalBroker.get_value(name)
    return _lastSignalResults[name]
end

--------- 
--- Connect to a signal.
--
--  brokerListrs["broker::cpu"] = function(e) ctr.addToCnt(1, createCpu(e.value)) end
--
--  for signal, func in pairs(brokerListrs) do
--      broker.connect_signal(signal, func)
--  end
--
-- @param string name   - The name of the signal.
-- @param function func - The callback to call when the signal is emitted.
function signalBroker.connect_signal(name, func)
    assert(type(func) == "function", "callback must be a function, got: " .. type(func))
    local signal = get_or_register_signal(name)
    signal.registeredFunctions[func] = true
    -- call callback function in case a value exists
    local val = signalBroker.get_value(name)
    if val then
        func(val)
    end
end

---------
--- Disonnect a function from a signal.
--
-- @param string name   - The name of the signal.
-- @param function func - The callback that should be disconnected.
function signalBroker.disconnect_signal(name, func)
    local signal = get_or_register_signal(name)
    signal.registeredFunctions[func] = nil
end

-------------------
--  Emit a signal.
--
-- signalBroker.emit_signal("broker::cpu", { value = cpu_now } ) 
--
-- @param string name - The name of the signal
-- @param val - value argument for the callback functions. Each connected
--   function receives the object as first argument is given to emit_signal()
function signalBroker.emit_signal(name, val)
    _lastSignalResults[name] = val
    local signal = get_or_register_signal(name)
    for func in pairs(signal.registeredFunctions) do
        func(val)
    end
end

-------------------
--  registers an signal which will be emitted timed 
--
-- TODO The timer will be started as soon the first client is connected to the signal.
-- If all clients where disconnected the timer will be suspended until the next 
-- client connects to the signal again.
--
-- @param string name       - name of the signal
-- @param functionToCall    - function which will provide the value argument 
--                            for the emiting through the broker
-- @param timeout           - integer timeout for the time interval until update
-- @param autostart         - should the timer started directly  
--
----
--  !! TODO start and stop timer in case no one is connected to the signal
---
function signalBroker.register_timed_signal(name, functionToCall, timeout)
    emitted_function = function()
        local value = functionToCall()
        log.trace(inspect(value))
        signalBroker.emit_signal(name, value)          
    end
    local localtimer = timer({ timeout = timeout, callback = emitted_function, call_now = true })
    localtimer:start()

    localtimer:connect_signal("timeout", emitted_function)
    localtimer:emit_signal("timeout")    
end

return signalBroker