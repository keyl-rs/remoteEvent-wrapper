local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CommShared = require(ReplicatedStorage.Shared.CommShared)
local GoodSignal = require(ReplicatedStorage.Utilities.goodsignal)

local serverClock = os.clock()
local CommServer = {}

CommServer.Events = { --Rate limits are per second.
	testEvent = {
		rateLimit = 5,
		signal = GoodSignal.new(),
		requestLog = {},
	},
}

function CommServer:Validate(player: Player, eventName: string, args: { [any]: any })
	for i, v in args do
		local expectedType = CommShared.Events.TestEvent.Schema[i]
		if not expectedType then
			CommShared:Log(
				`Invalid argument, {i} is not a defined argument for {eventName}`,
				CommShared.LogLevels.Error
			)
			return
		end

		local argType = typeof(v)
		if argType ~= expectedType then
			CommShared:Log(
				`Argument type for {eventName} is invalid. Expected {expectedType}, instead got {argType}`,
				CommShared.LogLevels.Error
			)
			return
		end
	end

	local playerRequests = CommServer.Events.testEvent.requestLog[player] or 0
	local rateLimit = CommServer.Events.testEvent.rateLimit

	if playerRequests == rateLimit then
		CommShared:Log(`Rate limited reached for {player}, cannot continue with execution`, CommShared.LogLevels.Error)
		return
	elseif playerRequests < rateLimit then
		CommServer.Events.testEvent.requestLog[player] = playerRequests + 1
	end

	return true
end

function CommServer.HeartBeat()
	if os.clock() - serverClock >= 1 then --resets every second
		CommServer.Events.testEvent.requestLog = {}
		serverClock = os.clock()
	end
end

for _, v: CommShared.EventEnum in CommShared.Events do
	local newRemote = Instance.new("RemoteEvent")
	newRemote.Name = v.Name

	newRemote.OnServerEvent:Connect(function(player: Player, args: { [any]: any })
		local signal: GoodSignal.Signal = CommServer.Events.testEvent.signal

		if CommServer:Validate(player, v.Name, args) then
			CommShared:Log("Event has passed validation, firing signal...", CommShared.LogLevels.Info)

			local success, result = pcall(function()
				signal:Fire(player, args, os.clock())
			end)

			if success then
				CommShared:Log(`Signal fired successfully: {result}`, CommShared.LogLevels.Info)
			else
				CommShared:Log(`Signal failed to fire: {result}`, CommShared.LogLevels.Error)
			end
		end
	end)

	newRemote.Parent = ReplicatedStorage.Shared.Events
end

RunService.Heartbeat:Connect(CommServer.HeartBeat)

return CommServer
