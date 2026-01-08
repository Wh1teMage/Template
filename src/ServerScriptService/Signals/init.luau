-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local schemas = require(ReplicatedStorage.Signals.schemas)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local types = require(ReplicatedStorage.Utilities.Signal.types)

return {
    Sync = Signal:CreateRemote('Sync') :: types.ServerScope<schemas.Sync>,
    Hydrate = Signal:CreateRemote('Hydrate') :: types.ServerScope<schemas.Hydrate>,
    Test = Signal:CreateBindable('Test') :: types.BindableScope<schemas.Test>,
    Test123 = Signal:CreateBindable('Test123') :: types.BindableScope<schemas.Test123>,
    Test3 = Signal:CreateRemote('Test3') :: types.ServerScope<schemas.Test3>,
}