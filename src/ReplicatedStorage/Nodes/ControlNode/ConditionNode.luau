local entryPoint = require(script.Parent.Parent.entryPoint)
local Wrapper = entryPoint.Wrapper
local controlNode = require(script.Parent)

local node = {} :: ConditionNode

export type ConditionNode = controlNode.Node & {
    thenNode: controlNode.Node?,
    elseNode: controlNode.Node?,

    Then: (self: ConditionNode, child: controlNode.Node) -> ConditionNode,
    Else: (self: ConditionNode, child: controlNode.Node) -> ConditionNode,
}

function node.new(children)
    local self = setmetatable(controlNode.new(children), {__index = node}) :: any

    return self :: ConditionNode
end

function node._onStart(self: ConditionNode)
    local result = true

    for _, child in ipairs(self.children) do
        child.context = self.context
        child:start()
        if (child.status == 'cancelled') then result = false; break end
        child:complete()
    end

    if (result) then 
        if (not self.thenNode) then return end
        self.thenNode.context = self.context
        self.thenNode:start()
    else
        if (not self.elseNode) then return end
        self.elseNode.context = self.context
        self.elseNode:start()
    end
end

function node.Then(self: ConditionNode, child: controlNode.Node)
    self.thenNode = child
    return self
end

function node.Else(self: ConditionNode, child: controlNode.Node)
    self.elseNode = child
    return self
end

return Wrapper(node, controlNode) 