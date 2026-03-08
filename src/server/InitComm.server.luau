local ServerScriptService = game:GetService("ServerScriptService")
local CommServer = require(ServerScriptService.Server.CommServer)

CommServer.Events.testEvent.signal:Connect(function(player: Player, args: { [any]: any }, time: number)
	print(`[{player.Name}][{time}] Test request received! args:`, args)
end)
