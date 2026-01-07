local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm = require(ReplicatedStorage.Packages.charm)
local charm_sync = require(ReplicatedStorage.Packages["charm-sync"])
local test = require(ReplicatedStorage.Utilities.Replica.atoms)
local Signal = require(ReplicatedStorage.Utilities.Signal)

local replicas = {}

local testAtom = charm.atom({['test'] = 123})

local bar = {
    hi = testAtom
}

local syncer = charm_sync.server({ atoms = test })

syncer:connect(function(player, payload)
	Signal:GetEvent('Sync'):Fire('sync', player, payload)
end)

Signal:GetEvent('Sync'):Connect('hydrate', function(player)
    syncer:hydrate(player)
end)

task.spawn(function()
    while (task.wait(2)) do
        test.hi({
            test = math.random(0,100)
        })
    end
end)


return {}
