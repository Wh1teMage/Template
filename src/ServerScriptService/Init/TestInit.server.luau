local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local PrintNode = require(ReplicatedStorage.Nodes.ActionNode.Overall.PrintNode)
local ConditionNode = require(ReplicatedStorage.Nodes.ControlNode.ConditionNode)
local Sequence = require(ReplicatedStorage.Nodes.ControlNode.Sequence)
local server = require(ReplicatedStorage.Utilities.Replica.server)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Serializer = require(ReplicatedStorage.Utilities.Signal.Serializer)

local Registry = require(ServerScriptService.Container.Registry)
local Signals = require(ServerScriptService.Signals)

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

Signals.Test:Connect(function(payload)
    print(payload)
end)

Signals.Test:Fire({message = 'hi'})

Signals.Test2:Connect(function(player: Player, payload)
    print(payload, 'recieved')
end)

local data = Serializer:Serialize({['test'] = 123})
print(buffer.len(data), Serializer:Deserialize(data))