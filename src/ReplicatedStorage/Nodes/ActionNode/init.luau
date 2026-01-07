local entryPoint = require(script.Parent.entryPoint)
local ParentNode = entryPoint.Node
local Wrapper = entryPoint.Wrapper

export type Node = {
    context: {[any]: any}
} & entryPoint.Node

local node = {} :: Node

function node.new()
    local self = setmetatable(ParentNode.new(), node) :: any

    self.context = nil

    return self :: Node
end

return Wrapper(node, ParentNode)
