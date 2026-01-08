local entryPoint = require(script.Parent.Parent.entryPoint)
local Wrapper = entryPoint.Wrapper
local controlNode = require(script.Parent)

local node = {} :: Node

export type Node = entryPoint.construct<{
    thenNode: entryPoint.Node?,
    elseNode: entryPoint.Node?,

    Then: (self: any, child: any) -> {
        Else: (self: any, child: any) -> nil
    },
    Else: (self: any, child: any) -> {
        Then: (self: any, child: any) -> nil
    },
}, controlNode.Node, (children: {any}) -> any>


function node.new(children)
    local self = setmetatable(controlNode(children), {__index = node}) :: any

    return self
end

function node._onStart(self: Node)
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

function node.Then(self: Node, child: entryPoint.Node)
    self.thenNode = child
    return self :: any
end

function node.Else(self: Node, child: entryPoint.Node)
    self.elseNode = child
    return self :: any
end

return Wrapper(node, controlNode) 