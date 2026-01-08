local ReplicatedStorage = game:GetService("ReplicatedStorage")

local schemas = require(ReplicatedStorage.Signals.schemas)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local types = require(ReplicatedStorage.Utilities.Signal.types)

return {
    Sync = Signal:CreateRemote('Sync') :: types.ServerScope<schemas.Sync>,
    Hydrate = Signal:CreateRemote('Hydrate') :: types.ServerScope<schemas.Hydrate>,
    Test = Signal:CreateBindable('Test') :: types.BindableScope<schemas.Test>,
    Test2 = Signal:CreateRemote('Test2') :: types.ServerScope<schemas.Test2>,
}