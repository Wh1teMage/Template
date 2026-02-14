local Atoms = require("@Info/Atoms")
local charm_sync = require("@Packages/charm-sync")
local Signals = require("@ServerScriptService/Signals")
--[[
local syncer = charm_sync.server({ atoms = Atoms :: any })

syncer:connect(
	function(
		player: Player,
		...: { data: { [number | string]: any }, type: "init" } | { data: { [number | string]: any }, type: "patch" }
	)
		print(...)
		Signals.Sync:Fire(player, ...)
	end
)

Signals.Hydrate:Connect(function(player: Player, payload)
	syncer:hydrate(player)
end)

task.spawn(function()
	while task.wait(1) do
		Atoms.Test(function(oldValue: typeof(Atoms.Test()))
			local newValue = table.clone(oldValue)
			newValue.bar.test += 1
			return newValue
		end)

		---print(Atoms.Test())
	end
end)

return {}
]]
