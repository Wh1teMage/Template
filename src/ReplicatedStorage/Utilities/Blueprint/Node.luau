local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Info.Enums)
local Wrapper = require(script.Parent.Wrapper)
local types = require(script.Parent.types)

export type Node = {
    ['new']: () -> Node,
} & types.Node 


local node = {} :: Node

function node.new()
    local self = setmetatable({
        status = Enums.NodeStatus.Idle,
        context = {},
    }, {__index = node})

    return self :: Node
end

function node._onStart(self: Node)
    
end

function node._onComplete(self: Node)
    
end

function node._onCancel(self: Node)
    
end

function node.start(self: Node)
    node.status = Enums.NodeStatus.Running
    self:_onStart()
end

function node.complete(self: Node)
    self:_onComplete()
    node.status = Enums.NodeStatus.Completed
end

function node.cancel(self: Node)
    self:_onCancel()
    node.status = Enums.NodeStatus.Cancelled
end

return Wrapper(node)
