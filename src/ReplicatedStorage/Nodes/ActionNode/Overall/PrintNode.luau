local entryPoint = require(script.Parent.Parent.Parent.entryPoint)
local Wrapper = entryPoint.Wrapper
local controlNode = require(script.Parent.Parent)

export type Node = entryPoint.construct<{
	["new"]: (params: string) -> entryPoint.Node,
	param: any,
}, controlNode.Node, (param: string) -> any>

local node = {} :: Node

function node.new(param: string)
	local self = setmetatable(controlNode(), node) :: any

	self.param = param

	return self
end

function node._onStart(self: Node)
	print("PrintNode:", self.context, self.param)
end

return Wrapper(node, controlNode)
