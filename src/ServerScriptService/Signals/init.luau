-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gt = require('@Packages/greentea')
local schemas = require(ReplicatedStorage.Signals.schemas)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local types = require(ReplicatedStorage.Utilities.Signal.types)

return {
    Test3 = Signal:CreateRemote('Test3', gt.typecast(schemas.Test3)) :: types.ServerScope<typeof(schemas.Test3)>,
}