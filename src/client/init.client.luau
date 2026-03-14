local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommClient = require(ReplicatedStorage.Shared.CommClient)
local CommShared = require(ReplicatedStorage.Shared.CommShared)

local _Overflow = false

CommClient:Send(CommShared.Events.TestEvent, {
	number = 455,
	text = "hello",
})

CommClient.Events.testEvent:Connect(function(args: {})
	print(`[{time}] Hello from Client! args:`, args)
end)

while _Overflow do
	CommClient:Send(CommShared.Events.TestEvent, {
		number = 455,
		text = "hello",
	})

	task.wait()
end
