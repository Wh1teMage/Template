local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Signals = require(ServerScriptService.Signals)
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
    Signals.Sync:Fire(player, payload)
end)

Signals.Hydrate:Connect(function(player)
    syncer:hydrate(player)
    print(player, 'hydrated')
end)

task.spawn(function()
    while (task.wait(2)) do
        test.PlayerAtom({
            num = math.random(1, 10)
        })
    end
end)


return {}
