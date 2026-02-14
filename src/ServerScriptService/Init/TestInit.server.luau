local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ConditionNode = require("@ReplicatedStorage/Nodes/ControlNode/ConditionNode")
local TestCombat = require("@ReplicatedStorage/TestCombat")
local initializator = require("@ReplicatedStorage/TestCombat/initializator")

local Container = require("@Utilities/Container")
local PrintNode = require(ReplicatedStorage.Nodes.ActionNode.Overall.PrintNode)
local Sequence = require(ReplicatedStorage.Nodes.ControlNode.Sequence)

local Signals = require(ServerScriptService.Signals)

local container = Container.new()

container:RegisterDirectory(ServerScriptService)
container:Start()

local ability = Sequence({
	PrintNode("123"),
	PrintNode("123"),
})

ability.context = {
	["test"] = "123",
}

ability:start()

Signals.Test3:Connect(function(player, payload)
	print(payload)
end)

--local data = Serializer:Serialize({['test'] = 123})
--print(buffer.len(data), Serializer:Deserialize(data))

local TestComponentCopy = require(ServerScriptService.Components.TestComponentCopy)

local test = TestCombat:CreateActor("Default", "123")
print(test)
--print(TestComponentCopy)
