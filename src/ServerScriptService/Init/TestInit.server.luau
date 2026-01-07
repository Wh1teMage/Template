local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local PrintNode = require(ReplicatedStorage.Nodes.ActionNode.Overall.PrintNode)
local ConditionNode = require(ReplicatedStorage.Nodes.ControlNode.ConditionNode)
local Sequence = require(ReplicatedStorage.Nodes.ControlNode.Sequence)
local server = require(ReplicatedStorage.Utilities.Replica.server)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Serializer = require(ReplicatedStorage.Utilities.Signal.Serializer)

local Registry = require(ServerScriptService.Container.Registry)

local container = Registry()

print(container.Elements)

local ability = Sequence{
    PrintNode('123'),
    PrintNode('869')
}

ability.context = {
    ['test'] = '123'
}

ability:start()

Signal:GetBindable('Test'):Connect('test', function(...: any)
    print(...)
end)

Signal:GetBindable('Test'):Fire('test', 'hi', 'hello')

local data = Serializer:Serialize({['test'] = 123})
print(buffer.len(data), Serializer:Deserialize(data))