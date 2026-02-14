local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Info.Enums)

local entryPoint = require(script.Parent.Parent.entryPoint)
local Wrapper = entryPoint.Wrapper
local controlNode = require(script.Parent)

local node = {} :: controlNode.Node

function node.new(children)
	local self = setmetatable(controlNode(children), node) :: any

	return self :: controlNode.Node
end

function node._onStart(self: controlNode.Node)
	for _, child in ipairs(self.children) do
		child.context = self.context
		child:start()
		if child.status == Enums.NodeStatus.Cancelled then return end
		child:complete()
	end
end

return Wrapper(node, controlNode)
