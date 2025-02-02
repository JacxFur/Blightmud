local function get_args(cmd)
	local args={}
	for str in string.gmatch(cmd, "([^%s]+)") do
		table.insert(args, str)
	end
	return args
end

local function info(...)
    local args = {...}
    for _,msg in ipairs(args) do
        print("[**] " .. msg)
    end
end

local function error(...)
    local args = {...}
    for _,msg in ipairs(args) do
        print(cformat("<red>[!!]<reset> %s", msg))
    end
end

local function print_mud_output_usage()
	info("USAGE: /test <some string to test>")
end

alias.add("^/test$", function ()
	print_mud_output_usage()
end)

alias.add("^/test (.*)$", function (matches)
	local line = matches[2]:gsub("%s+", " ")
	if line:len() > 0 then
		mud.output(line)
	else
		print_mud_output_usage()
	end
end)

local function state_label (state, label)
	local color = C_RED
	if state then
		color = C_GREEN
	end
	return color .. label .. C_RESET
end

local function number_label (number, label)
	local color = C_RED
	if number and number > 0 then
		color = C_GREEN
	end
	return label .. color .. tostring(number) .. C_RESET
end

alias.add("^/aliases$", function ()
	for id,alias in pairs(alias.get_group():get_aliases()) do
		local enabled = state_label(alias.enabled, "enabled")
		info(cformat("%s :\t<yellow>%s<reset>\t%s", id, alias.regex:regex(), enabled))
	end
end)

alias.add("^/triggers$", function ()
	for id,trigger in pairs(trigger.get_group():get_triggers()) do
		local enabled = state_label(trigger.enabled, "enabled")
		local gag = state_label(trigger.gag, "gag")
		local raw = state_label(trigger.raw, "raw")
		local prompt = state_label(trigger.prompt, "prompt")
		local count = number_label(trigger.count, "count: ")
		info(cformat("%s :\t<yellow>%s<reset>\t%s\t%s\t%s\t%s\t%s", id, trigger.regex:regex(), enabled, gag, raw, prompt, count))
	end
end)

alias.add("^/tts (on|off)$", function (matches)
	tts.enable(matches[2] == "on")
end)

alias.add("^/tts_rate ([-\\d]+)$", function (matches)
	tts.set_rate(matches[2])
end)

alias.add("^/tts_keypresses (on|off)$", function (matches)
	tts.echo_keypresses(matches[2] == "on")
end)

alias.add("^/settings$", function ()
	for key, value in pairs(settings.list()) do
		local key_format = cformat("<yellow>%s<reset>", key)
		local value_format
		if value then
			value_format = cformat("<bgreen>on<reset>")
		else
			value_format = cformat("<bred>off<reset>")
		end
		info(cformat("%s => %s", key_format, value_format))
	end
end)

alias.add("^/set ([^\\s]+)\\s*(on|off)?$", function (matches)
	local settings_table = settings.list()
	local key = matches[2]
	if settings_table[key] == nil then
		info(cformat("<red>Unknown setting: %s<reset>", key))
	else
		local value
		if matches[3] == "" then
			value = settings_table[key]
		else
			value = matches[3] == "on"
			settings.set(key, value)
		end
		local key_format = cformat("<yellow>%s<reset>", key)
		local value_format
		if value then
			value_format = cformat("<bgreen>on<reset>")
		else
			value_format = cformat("<bred>off<reset>")
		end
		blight.output(cformat("%s => %s", key_format, value_format))
	end
end)

alias.add("^/connect.*$", function (m)
    local args = get_args(m[1])
    if #args == 2 then
        mud.connect_server(args[2])
    elseif #args == 3 then
        mud.connect(args[2], args[3], args[4])
    elseif #args >= 4 then
        mud.connect(args[2], args[3], args[4])
    else
        info(
            "USAGE: /connect <host> <port> [<tls>]",
            "USAGE: /connect <server>",
            "EXAMPLE: /connect examplemud.org 4000",
            "EXAMPLE: /connect example-tls-mud.org 4000 true",
            "EXAMPLE: /connect stored-server-name"
            )
    end
end)
alias.add("^(:?/disconnect|/dc)$", function ()
    mud.disconnect()
end)
alias.add("^(:?/reconnect|/rc)$", function ()
    mud.reconnect()
end)
alias.add("^/start_log.*$", function (m)
    local args = get_args(m[1])
    if #args == 2 then
        log.start(args[2])
    else
        info("USAGE: /start_log <name>")
    end
end)
alias.add("^/stop_log$", function ()
    log.stop()
end)
alias.add("^/load.*$", function (m)
    local args = get_args(m[1])
    if #args > 1 then
        script.load(table.concat(args, " ", 2))
    else
        info("USAGE: /load <path>")
    end
end)
