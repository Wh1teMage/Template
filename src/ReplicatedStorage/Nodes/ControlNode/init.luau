local entryPoint = require(script.Parent.entryPoint)
local ParentNode = entryPoint.Node
local Wrapper = entryPoint.Wrapper

export type Node =  {
    children: {entryPoint.Node},
    ['new']: (children: {any}) -> Node
} & entryPoint.Node

local node = {} :: Node

function node.new(children)
    local self = setmetatable(ParentNode.new(), node) :: any
    
    self.children = children

    return self :: Node
end

function node._onCancel(self: Node)
    for _, child in ipairs(self.children) do
        child:cancel()
    end
end

return Wrapper(node, ParentNode)