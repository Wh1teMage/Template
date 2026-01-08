local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm = require(ReplicatedStorage.Packages.charm)
local charm_sync = require(ReplicatedStorage.Packages["charm-sync"])
local Signals = require(ReplicatedStorage.Signals)
local atoms = require(ReplicatedStorage.Utilities.Replica.atoms)
local Signal = require(ReplicatedStorage.Utilities.Signal)

local syncer = charm_sync.client({ atoms = atoms })

Signals.Sync:Connect(function(payload)
    syncer:sync(payload)
    print(payload)
end)

--Events.RequestState:Fire()
Signals.Hydrate:Fire()

return {}