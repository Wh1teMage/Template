local Atoms = require("@Info/Atoms")
local charm_sync = require("@Packages/charm-sync")
local Signals = require("@ReplicatedStorage/Signals")
--[[
local syncer = charm_sync.client({ atoms = Atoms :: any })

Signals.Sync:Connect(function(...)
	print(...)
	syncer:sync(...)
end)

Signals.Hydrate:Fire()

return {}
]]
