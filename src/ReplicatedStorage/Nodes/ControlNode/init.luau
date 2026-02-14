local entryPoint = require(script.Parent.entryPoint)
local ParentNode = entryPoint.Node
local Wrapper = entryPoint.Wrapper

export type Node = entryPoint.construct<{
	children: { entryPoint.Node },
}, entryPoint.Node, (children: { any }) -> any>

local node = {} :: Node

function node.new(children)
	local self = setmetatable(ParentNode(), node) :: any

	self.children = children

	return self
end

function node._onCancel(self: Node)
	for _, child in ipairs(self.children) do
		child:cancel()
	end
end

return Wrapper(node, ParentNode)
