-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Utilities.Signal)
local types = require(ReplicatedStorage.Utilities.Signal.types)
local schemas = require(script.schemas)

return {
    Sync = Signal:CreateRemote('Sync') :: types.ClientScope<schemas.Sync>,
    Hydrate = Signal:CreateRemote('Hydrate') :: types.ClientScope<schemas.Hydrate>,
    Test3 = Signal:CreateRemote('Test3') :: types.ClientScope<schemas.Test3>,
}