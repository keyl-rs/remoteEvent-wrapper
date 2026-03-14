local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommShared = require(ReplicatedStorage.Shared.CommShared)
local GoodSignal = require(ReplicatedStorage.Utilities.goodsignal)

local Events = ReplicatedStorage.Shared.Events

local CommClient = {}

CommClient.Events = {}

function CommClient:Send(eventEnum: CommShared.EventEnum, args: {})
	local Event: RemoteEvent = Events:FindFirstChild(eventEnum.Name)

	if Event then
		Event:FireServer(args)
		CommShared:Log(`Client has fired Remote Event successfully`, CommShared.LogLevels.Info)
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

for _, v: CommShared.EventEnum in CommShared.Events do
	local newRemote = ReplicatedStorage.Shared.Events:WaitForChild(v.Name)
	CommClient.Events[v.Name] = GoodSignal.new()

	newRemote.OnClientEvent:Connect(function(args: { [any]: any })
		local signal: GoodSignal.Signal = CommClient.Events[v.Name]

		local success, result = pcall(function()
			signal:Fire(args)
		end)

		if success then
			CommShared:Log(`Signal fired successfully: {v.Name}`, CommShared.LogLevels.Info)
		else
			CommShared:Log(`Signal failed to fire: {result}`, CommShared.LogLevels.Error)
		end
	end)

	newRemote.Parent = ReplicatedStorage.Shared.Events
end

return CommClient
