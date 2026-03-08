local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommClient = require(ReplicatedStorage.Shared.CommClient)
local CommShared = require(ReplicatedStorage.Shared.CommShared)

local _sendOverflow = true

CommClient:Send(CommShared.Events.TestEvent, {
	number = 455,
	text = "hello",
})

while _sendOverflow do
	CommClient:Send(CommShared.Events.TestEvent, {
		number = 455,
		text = "hello",
	})

	task.wait()
end
