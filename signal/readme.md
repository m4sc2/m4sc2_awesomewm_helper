## Emit signal

Register/Emit an new signal at the signal broker

```c++
 broker.emit_signal("broker::cpu", { value = cpu_now } )
```
## Connect to a signal

Register a callback function for an existing signal. which each emit signal all registered callback
functions will be called with the value emited through the signal

```c++
    local function createCpu(cpu)
        return createGadgetPie("CPU %", cpu.usage, "cpu "..cpu.usage.."%")
    end

    brokerListrs["broker::cpu"] = function(e) createCpu(e.value) end
    
    for signal, func in pairs(brokerListrs) do
        broker.connect_signal(signal, func)
    end    
```

## Disconect an callback from a signal

```c++
    for signal, func in pairs(brokerListrs) do
        broker.disconnect_signal(signal, func)
    end  

```

## Register an timed emit_signal 

```c++
//TODO add example
```
