local entryPoint = require(script.Parent.Parent.Parent.entryPoint)
local Wrapper = entryPoint.Wrapper
local controlNode = require(script.Parent.Parent)

export type Node = entryPoint.construct<{
    ['new']: (scope: string) -> entryPoint.Node,
    scope: string
}, controlNode.Node, (scope: string) -> any>

local node = {} :: Node

function node.new(scope: string)
    local self = setmetatable(controlNode(), node) :: any

    self.scope = scope

    return self
end

function node._onStart(self: Node)
    return self.context[self.scope]
end

return Wrapper(node, controlNode)