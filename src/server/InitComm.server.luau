local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommServer = require(ServerScriptService.Server.CommServer)
local CommShared = require(ReplicatedStorage.Shared.CommShared)

CommServer.Events.testEvent.signal:Connect(function(player: Player, args: { [any]: any })
	local time = os.clock()

	print(`[{player.Name}][{time}] Hello from Server! args:`, args)
end)

task.delay(5, function()
	CommServer:SendAllClients(CommShared.Events.TestEvent, {
		number = 5,
		text = "hiii client :3",
	})
end)
