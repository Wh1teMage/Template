local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Utilities.Signal)
local types = require(ReplicatedStorage.Utilities.Signal.types)

local schemas = require(script.schemas)

return {
    Sync = Signal:CreateRemote('Sync') :: types.ClientScope<schemas.Sync>,
    Hydrate = Signal:CreateRemote('Hydrate') :: types.ClientScope<schemas.Hydrate>,
    Test2 = Signal:CreateRemote('Test2') :: types.ClientScope<schemas.Test2>,
}