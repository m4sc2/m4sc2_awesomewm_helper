local awful = require("awful")
local helpers = {}

function helpers.run_once_ps(findme, cmd)
	awful.spawn.easy_async_with_shell(string.format("ps -C %s|wc -l", findme), function(stdout)
		if tonumber(stdout) ~= 2 then
			awful.spawn(cmd, false)
		end
	end)
end

function helpers.run_once_grep(command)
	awful.spawn.easy_async_with_shell(string.format("ps aux | grep '%s' | grep -v 'grep'", command), function(stdout)
		if stdout == "" or stdout == nil then
			awful.spawn(command, false)
		end
	end)
end



return helpers