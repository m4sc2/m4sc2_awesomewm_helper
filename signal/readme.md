# Signal Broker

## Credits

[raven2cz](https://github.com/raven2cz) as idea provider and creator of the original version
[repo](https://github.com/raven2cz/awesomewm-config/blob/master/fishlive/signal/broker.lua)

## Init Broker

just add

```c++
broker = require("helpers.signal.signal_broker")
```
to your rc.lua

## Emit a Signal

Register/Emit an new signal at the signal broker

```c++
 broker.emit_signal("broker::cpu", { value = cpu_now } )
```
## Emit a Signal with Timer 

At the signal broker a timer will call the registered function. The output of the function will than be emitted via "Emit a Signal"

```c++
    ...
    timeout = 1

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

    ...
```
## Connect to a Signal

Register a callback function for an existing signal. With each emitted signal all registered callback
functions will be called. With the value emitted through the signal.

```c++

    local function createCpu(cpu)
        return createWidget("CPU %", cpu.usage, "cpu "..cpu.usage.."%")
    end
    
    ...
    
    broker.connect_signal("broker::cpu", function(e) createCpu(e.value) end)

    ...
```

## Disconect a Callback Function from a Signal
In case a Callback Function is not neccessary anymore it can be disconnected, de-registered at the broker. 

```c++
    ...
    broker.disconnect_signal("broker::cpu", function(e) createCpu(e.value) end)
    ...
```

# Signals

## volume-signal

Provides and Handles Signals related to sound devices

### Usage

```c++
require('helpers.signal.signals.volume-signal'){}
```

### Signals
name|type|description
---|---|---
broker::volume             | signal_emit      | list            
broker::volume_change_sink | signal_connect   | change default device   
broker::volume_increase    | signal_connect   | change +volume 
broker::volume_decrease    | signal_connect   | change -volume  
broker::volume_mixer       | signal_connect   | open mixer app
broker::volume_mute        | signal_connect   | toggle mute 

TODO add info for parameter past to the signal in case of signal_connect

## cpu-signal

Provides and Handles Signals related to CPU.

### Usage

```c++
require('helpers.signal.signals.cpu-signal'){}
```

### Signals
name|type|description
---|---|---
broker::cpu | signal_emit|provides current cpu load         
 
## network-signal

Provides and Handles Signals related to network devices.

### Credits

Original by [lcpz](https://github.com/lcpz/lain)

### Usage

```c++
require('helpers.signal.signals.networl-signal'){}
```

### Signals
name|type|description
---|---|---
broker::network|signal_emit|list devices and tx/rx values
