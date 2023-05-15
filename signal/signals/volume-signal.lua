---------------------------------------------------------------------------
---                     Volume Signals                                  ---
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--- @author m4sc2                                                       ---
---                                                                     ---
---  Provides and Handles Signals related to sound devices:             ---
---   * broker::volume             - signal_emit      - list            ---
---   * broker::volume_change_sink - signal_connect   - change device   ---
---   * broker::volume_increase    - signal_connect   - change +volume  ---
---   * broker::volume_decrease    - signal_connect   - change -volume  ---
---   * broker::volume_mixer       - signal_connect   - open mixer app  ---
---   * broker::volume_mute        - signal_connect   - toggle mute     ---
---                                                                     ---
---------------------------------------------------------------------------
--- usage: require('widgets.masc.signals.volume-signal')                ---
---                                                                     ---
--- Requirement: pactl version >= 16.1                                  ---
---------------------------------------------------------------------------

local spawn = require("awful.spawn")
local json = require ("helpers.dkjson")
local filesystem = require("helpers.filesystem")

local function LIST_DEVICES_CMD() return [[sh -c "pactl -f json list sinks"]] end
local function DEFAULT_SINK_CMD() return [[sh -c "pactl get-default-sink"]] end
local function INCREASE_VOLUME_CMD(device, step) return string.format('pactl set-sink-volume %s +%s%%', device, step) end
local function DECREASE_VOLUME_CMD(device, step) return string.format('pactl set-sink-volume %s -%s%%', device, step) end
local function MUTE_VOLUME_CMD(device) return string.format('pactl set-sink-mute %s toggle', device) end
local function CHANGE_DEFAULT_SINK(device) return string.format([[sh -c 'pactl set-default-sink "%s"']], device) end


local volume = {sinks = {}, default_volume_level = 0}
local default_devicename = "default"

local function worker(user_args)
    args = user_args or {}
    local mixer_cmd = args.mixer_cmd or 'pavucontrol'
    local timeout = args.timeout or 0.3

    -- identify default sink at start up 
    -- --> FIXME in case the source will be changed outside there will be inconsistent data shown in the default values
    spawn.easy_async(DEFAULT_SINK_CMD(), function(stdout) default_devicename = filesystem.removeMultilines(stdout) end)

    function increase_volume(e)
        spawn.easy_async(INCREASE_VOLUME_CMD(e.devicename, e.step), function(stdout)  end)
    end

    function decrease_volume(e)
        spawn.easy_async(DECREASE_VOLUME_CMD(e.devicename, e.step), function(stdout)  end)
    end

    function toggle_mute(e)
        spawn.easy_async(MUTE_VOLUME_CMD(e.devicename), function(stdout) end)
    end

    function change_sink(e)
        spawn.easy_async(CHANGE_DEFAULT_SINK(e.devicename), function(stdout)  end)
        default_devicename = e.devicename
    end

    function open_mixer()
        spawn.easy_async(mixer_cmd)
    end
    
    function update()
        spawn.easy_async(LIST_DEVICES_CMD(), function(stdout) extract_sink_data(stdout) end)
        log.trace(inspect(volume))
        return volume
    end

    function extract_sink_data(stdout) 
        local sinks, pos, err = json.decode(stdout, 1, nil)       

        for _, device in pairs(sinks) do
            local sink_cur = {}
            sink_cur.mute = device.mute
            -- us [""] to access properties with incorrect letter e.g. minus
            sink_cur.volume_level = device.volume["front-left"].value_percent
            sink_cur.volume_level = string.gsub(sink_cur.volume_level,"%%","")
            sink_cur.device_name = device.name
            sink_cur.description = device.properties["device.product.name"]

            sink_cur.state = device.state
           
            -- fill current default sink information
            if device.name == default_devicename then
                volume.default_device_name = sink_cur.device_name
                volume.default_volume_level = sink_cur.volume_level
                volume.default_mute = sink_cur.mute
                volume.default_description = sink_cur.description
                volume.default_state = sink_cur.state
            end

            volume.sinks[sink_cur.device_name] = sink_cur
        end
        log.trace(inspect(volume))
    end

    broker.register_timed_signal("broker::volume", update, timeout)

    -- connect to triggered signals from the outside
    broker.connect_signal("broker::volume_increase", function(e) increase_volume(e) end)
    broker.connect_signal("broker::volume_decrease", function(e) decrease_volume(e) end)
    broker.connect_signal("broker::volume_mute", function(e) toggle_mute(e) end)
    broker.connect_signal("broker::volume_mixer", function(e) open_mixer(e) end)
    broker.connect_signal("broker::volume_change_sink", function(e) change_sink(e) end)

    return volume
end

return setmetatable(volume, { __call = function(_, ...) return worker(...) end })