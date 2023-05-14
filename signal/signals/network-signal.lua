---------------------------------------------------------------------------
---                     Network Information Signals                     ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--- @author m4sc2                                                       ---
---                                                                     ---
---  Provides and Handles Signals related to network devices:           ---
---   * broker::network - signal_emit   - list devices and tx/rx values ---
---                                                                     ---
---------------------------------------------------------------------------
--- usage: require('helpers.signal.signals.network-signal')             ---
---                                                                     ---
---------------------------------------------------------------------------
--- Credits:                                                            ---
---     Original by lcpz (https://github.com/lcpz/lain)                 ---
---------------------------------------------------------------------------

local awful = require("awful")
local iohelper = require("helpers.filesystem")

local network = {devs = {}}

local function worker(user_args)
    args = user_args or {}
    local units      = args.units or 1048576 -- MB
    local wifi_state = args.wifi_state or "off"
    local eth_state  = args.eth_state or "on"
    local format     = args.format or "%4.1f"
    local timeout    = args.timeout or 3
    
    -- Compatibility with old API where iface was a string corresponding to 1 interface
    network.iface = (args.iface and (type(args.iface) == "string" and {args.iface}) or
                (type(args.iface) == "table" and args.iface)) or {}

    function network.get_devices()
        network.iface = {} -- reset at every call
        iohelper.line_callback("ip link", function(line)
            network.iface[#network.iface + 1] = not string.match(line, "LOOPBACK") and string.match(line, "(%w+): <") or nil
        end)
    end

    if #network.iface == 0 then network.get_devices() end

    function network.update()

        -- These are the totals over all specified interfaces
        net_cur = {
            devs  = {},
            -- Bytes since last iteration
            sent     = 0,
            received = 0
        }

        for _, dev in ipairs(network.iface) do
            local dev_cur    = {}
            local now_t      = tonumber(iohelper.first_line(string.format("/sys/class/net/%s/statistics/tx_bytes", dev)) or 0)
            local now_r      = tonumber(iohelper.first_line(string.format("/sys/class/net/%s/statistics/rx_bytes", dev)) or 0)
            local dev_prev   = network.devs[dev] or { last_t = now_t, last_r = now_r }


            dev_cur.carrier  = iohelper.first_line(string.format("/sys/class/net/%s/carrier", dev)) or "0"
            dev_cur.state    = iohelper.first_line(string.format("/sys/class/net/%s/operstate", dev)) or "down"

            dev_cur.sent     = (now_t - dev_prev.last_t) / timeout / units
            dev_cur.received = (now_r - dev_prev.last_r) / timeout / units

            net_cur.sent     = net_cur.sent + dev_cur.sent
            net_cur.received = net_cur.received + dev_cur.received

            dev_cur.sent     = string.format(format, dev_cur.sent)
            dev_cur.received = string.format(format, dev_cur.received)

            dev_cur.last_t   = now_t
            dev_cur.last_r   = now_r

            if wifi_state == "on" and 
                iohelper.first_line(string.format("/sys/class/net/%s/uevent", dev)) == "DEVTYPE=wlan" then
                dev_cur.wifi   = true
                if string.match(dev_cur.carrier, "1") then
                    dev_cur.signal = tonumber(
                        string.match(iohelper.lines_from("/proc/net/wireless")[3], "(%-%d+%.)")) or nil
                end
            else
                dev_cur.wifi   = false
            end

            if eth_state == "on" and 
                iohelper.first_line(string.format("/sys/class/net/%s/uevent", dev)) ~= "DEVTYPE=wlan" then
                dev_cur.ethernet = true
            else
                dev_cur.ethernet = false
            end

            network.devs[dev] = dev_cur
            
            net_cur.carrier = dev_cur.carrier
            net_cur.state = dev_cur.state
            net_cur.devs[dev] = dev_cur              
        end

        net_cur.sent = string.format(format, net_cur.sent)
        net_cur.received = string.format(format, net_cur.received)
        network.net_cur = net_cur
        return network
    end

    broker.register_timed_signal("broker::network", network.update, timeout)

    return network
end

return setmetatable(network, { __call = function(_, ...) return worker(...) end })