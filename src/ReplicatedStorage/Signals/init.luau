-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gt = require('@Packages/greentea')
local Signal = require(ReplicatedStorage.Utilities.Signal)
local types = require(ReplicatedStorage.Utilities.Signal.types)
local schemas = require(script.schemas)

return {
    Test3 = Signal:CreateRemote('Test3', gt.typecast(schemas.Test3)) :: types.ClientScope<typeof(schemas.Test3)>,
}