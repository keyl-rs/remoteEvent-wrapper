local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local CommShared = require(ReplicatedStorage.Shared.CommShared)
local GoodSignal = require(ReplicatedStorage.Utilities.goodsignal)

local serverClock = os.clock()
local CommServer = {}

CommServer.Events = {}

function CommServer:Send(player: Player, eventEnum: CommShared.EventEnum, args: {}) --yes i just copied the client code lmao
	local Event: RemoteEvent = ReplicatedStorage.Shared.Events:FindFirstChild(eventEnum.Name)

	if Event then
		Event:FireClient(player, args)
		CommShared:Log(`Server has fired Remote Event successfully`, CommShared.LogLevels.Info)
	else
		for _, v: CommShared.EventEnum in CommShared.Events do
			if v.Name == eventEnum.Name then
				CommShared:Log(`Remote event instance for {eventEnum} is nil`, CommShared.LogLevels.Error)
				return
			end
		end

		CommShared:Log(`Event does not exist`, CommShared.LogLevels.Warn)
	end
end

function CommServer:SendAllClients(eventEnum: CommShared.EventEnum, args: {})
	for _, playerInstance: Player in Players:GetPlayers() do
		CommServer:Send(playerInstance, eventEnum, args)
	end
end

function CommServer:Validate(player: Player, eventName: string, args: { [any]: any })
	for i, v in args do
		local expectedType = CommShared.Events.TestEvent.Schema[i]
		if not expectedType then
			CommShared:Log(
				`Invalid argument, {i} is not a defined argument for {eventName}`,
				CommShared.LogLevels.Error
			)
			return false
		end

		local argType = typeof(v)
		if argType ~= expectedType then
			CommShared:Log(
				`Argument type for {eventName} is invalid. Expected {expectedType}, instead got {argType}`,
				CommShared.LogLevels.Error
			)
			return false
		end
	end

	local playerRequests = CommServer.Events[eventName].requestLog[player] or 0
	local rateLimit = CommServer.Events[eventName].rateLimit

	if playerRequests >= rateLimit then
		CommShared:Log(`Rate limited reached for {player}, cannot continue with execution`, CommShared.LogLevels.Error)
		return
	elseif playerRequests < rateLimit then
		CommServer.Events[eventName].requestLog[player] = playerRequests + 1
	end

	return true
end

function CommServer.HeartBeat()
	for _, v: {} in CommServer.Events do
		if os.clock() - serverClock >= 1 then --resets every second
			v.requestLog = {}
			serverClock = os.clock()
		end
	end
end

for _, v: CommShared.EventEnum in CommShared.Events do
	CommServer.Events[v.Name] = {
		rateLimit = v.RateLimit,
		signal = GoodSignal.new(),
		requestLog = {},
	}

	local newRemote = Instance.new("RemoteEvent")
	newRemote.Name = v.Name

	newRemote.OnServerEvent:Connect(function(player: Player, args: { [any]: any })
		local signal: GoodSignal.Signal = CommServer.Events[v.Name].signal

		if CommServer:Validate(player, v.Name, args) then
			CommShared:Log("Event has passed validation, firing signal...", CommShared.LogLevels.Info)

			local success, result = pcall(function()
				signal:Fire(player, args)
			end)

			if success then
				CommShared:Log(`Signal fired successfully: {v.Name}`, CommShared.LogLevels.Info)
			else
				CommShared:Log(`Signal failed to fire: {result}`, CommShared.LogLevels.Error)
			end
		end
	end)

	newRemote.Parent = ReplicatedStorage.Shared.Events
end

RunService.Heartbeat:Connect(CommServer.HeartBeat)

return CommServer
