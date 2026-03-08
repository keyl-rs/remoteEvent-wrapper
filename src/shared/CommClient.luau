local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommShared = require(ReplicatedStorage.Shared.CommShared)
local Events = ReplicatedStorage.Shared.Events

local CommClient = {}

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

return CommClient
