export type EventEnum = {
	Name: string,
	Schema: {
		[any]: any,
	},
	RateLimit: number,
}

local CommShared = {}

CommShared.Debug = true

CommShared.LogLevels = {
	Info = "INFO",
	Warn = "WARN",
	Error = "ERROR",
}

CommShared.Events = {
	TestEvent = {
		Name = "testEvent",
		Schema = {
			number = "number",
			text = "string",
		},
		RateLimit = 5,
	},
}

function CommShared:Log(msg: string, level: string)
	local logMessage = `[Comm][{level}][{os.clock()}] {msg}`

	if level == "INFO" and CommShared.Debug == true then
		print(logMessage)
	elseif level ~= "INFO" then
		warn(logMessage)
	end
end

return CommShared
