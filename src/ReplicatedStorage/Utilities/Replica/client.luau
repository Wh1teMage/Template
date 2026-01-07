local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.Events)
local charm = require(ReplicatedStorage.Packages.charm)
local charm_sync = require(ReplicatedStorage.Packages["charm-sync"])
local test = require(ReplicatedStorage.Utilities.Replica.atoms)
local Signal = require(ReplicatedStorage.Utilities.Signal)

local syncer = charm_sync.client({ atoms = test })

Signal:GetEvent('Sync'):Connect('sync', function(...: any)
    syncer:sync(...)
    print(...)
end)

--Events.RequestState:Fire()
Signal:GetEvent('Sync'):Fire('hydrate')

return {}