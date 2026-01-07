local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local PrintNode = require(ReplicatedStorage.Nodes.ActionNode.Overall.PrintNode)
local ConditionNode = require(ReplicatedStorage.Nodes.ControlNode.ConditionNode)
local Sequence = require(ReplicatedStorage.Nodes.ControlNode.Sequence)
local Signal = require(ReplicatedStorage.Utilities.Signal)

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