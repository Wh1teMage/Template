local attribute = {}
attribute.__index = attribute

local OperationType = {
	Add = "Add",
	Set = "Set",
	Multiply = "Multiply",
} :: {
	Add: "Add",
	Set: "Set",
	Multiply: "Multiply",
}

type Operation = { type: keyof<typeof(OperationType)>, value: number }

type InstanceFields = {
	read DefaultValue: number,
	ModifiedValue: number,
	_operations: { Operation },
}

export type Instance<T = {}> = setmetatable<InstanceFields & T, { __index: typeof(attribute) }>

function attribute.constructor(value: number)
	local self = setmetatable({
		DefaultValue = value,
	}, attribute) :: Instance

	self.ModifiedValue = value

	return self
end

local operationMap = {
	[OperationType.Add] = function(default: number, value: number)
		return default + value
	end,
	[OperationType.Set] = function(default: number, value: number)
		return value
	end,
	[OperationType.Multiply] = function(default: number, value: number)
		return default * value
	end,
}

local function _calculateModifiedValue(self: Instance)
	local value = self.DefaultValue

	for _, operation in self._operations do
		local selectedFunction = operationMap[operation.type]
		if not selectedFunction then continue end
		value = selectedFunction(value, operation.value)
	end

	self.ModifiedValue = value
end

local function _addOperation(self: Instance, operation: Operation)
	table.insert(self._operations, operation)
	_calculateModifiedValue(self)
	-- connect via event
	return operation
end

local function _removeOperation(self: Instance, operation: Operation)
	local index = table.find(self._operations, operation)
	assert(index, `Operation not found!`)

	table.remove(self._operations, index)
end

function attribute.Get(self: Instance)
	return self.ModifiedValue
end

function attribute.RemoveOperation(self: Instance, operation: Operation)
	_removeOperation(self, operation)
end

function attribute.Add(self: Instance, value: number)
	local operation = { type = OperationType.Add, value = value } :: Operation
	return _addOperation(self, operation)
end

function attribute.Set(self: Instance, value: number)
	local operation = { type = OperationType.Set, value = value } :: Operation
	return _addOperation(self, operation)
end

function attribute.Multiply(self: Instance, value: number)
	local operation = { type = OperationType.Multiply, value = value } :: Operation
	return _addOperation(self, operation)
end

function attribute.Reset(self: Instance)
	table.clear(self._operations)
	_calculateModifiedValue(self)
end
-- ^ should we use some kind of DefaultValue validation instead?
-- v * 5 + 5 -> v / 5 - 5 (incorrect async order)
-- ^ what should we do with these variants?
-- returns an operation with discard method?

-- save modified value
-- also save the order of operations
-- whenever theres a new operation recalculate modified value and store it
-- ^ this instead of direct operations with modified value

return attribute
