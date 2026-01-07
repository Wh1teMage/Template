local entryPoint = require(script.Parent.Parent.Parent.entryPoint)
local Wrapper = entryPoint.Wrapper
local controlNode = require(script.Parent.Parent)

export type Node = {
    ['new']: (params: string) -> Node,
    param: any,
} & controlNode.Node

local node = {} :: Node

function node.new(param: any)
    local self = setmetatable(controlNode.new(), node) :: any

    self.param = param

    return self :: Node
end

function node._onStart(self: Node)
    print("PrintNode:", self.context, self.param)
end

return Wrapper(node, controlNode)