# m4sc2_awesomewm_helper
Is a collection of helper for ricing/creation of AwesomeWM widgets/configs.


## log - logging
---
by [rxi](https://github.com/rxi/log.lua)

simple but very useful logging lib

### Usage: 

```c
log = require ("log.log")

--- define logging 
-- file path
log.outfile = os.getenv("HOME") .."/lua-log.log"
--possible log level - "trace" "debug" "info" "warn" "error" "fatal"
log.level = "debug"

Modes:
    log.trace(...)
    log.debug(...)
    log.info(...)
    log.warn(...)
    log.error(...)
    log.fatal(...)
```
## inspect - human-readable representations of tables
---
by [kikito](https://github.com/kikito/inspect.lua)

amazing lib for creation debug output for lua tables

### Usage:

```c
inspect = require("inspect.inspect")

log.trace(inspect(stdout))
```

## icon_customizer
---
by [intrntbrn](https://github.com/intrntbrn/icon_customizer)

Features:
------------
- Define your own icons for applications
- Set custom icons for terminal applications based on client title

### Usage:

[example-configuration](https://github.com/intrntbrn/icon_customizer#example-configuration)

## dkjson - JSON Module for Lua
---
by [dkolf](http://dkolf.de/src/dkjson-lua.fsl)

easy encode/decode lua tables in json and vice versa

### Usage:
The same example below and more can also be found at the wiki of the author


**Encoding**
---
---

```c

local json = require ("dkjson")

local tbl = {
  animals = { "dog", "cat", "aardvark" },
  instruments = { "violin", "trombone", "theremin" },
  bugs = json.null,
  trees = nil
}

local str = json.encode (tbl, { indent = true })

print (str)

```

**Output**

```c
{
  "bugs":null,
  "instruments":["violin","trombone","theremin"],
  "animals":["dog","cat","aardvark"]
}
```

**Decoding**
---
---

```c

local json = require ("dkjson")

local str = [[
{
  "numbers": [ 2, 3, -20.23e+2, -4 ],
  "currency": "\u20AC"
}
]]

local obj, pos, err = json.decode (str, 1, nil)
if err then
  print ("Error:", err)
else
  print ("currency", obj.currency)
  for i = 1,#obj.numbers do
    print (i, obj.numbers[i])
  end
end
```

**Output**

```c
currency	€
1	2
2	3
3	-2023
4	-4
```