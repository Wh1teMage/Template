local Attribute = require("../Components/AttributeComponent")
local sift = require("@Packages/sift")

local attributeSet = {}
attributeSet.__index = attributeSet

type Fields<T> = {
	new: () -> Instance<T>,
	read _data: T,
}

type InstanceFields<T> = {
	id: string,
	data: changeMapValues<T, Attribute.Instance>,
}

export type Class<data = {}, T = {}> = setmetatable<Fields<data> & T, { __index: typeof(attributeSet) }>
export type Instance<data = {}> = setmetatable<InstanceFields<data>, { __index: typeof(attributeSet) }>

type function validateMap(set: type, valueType: type)
	assert(set:is("table"), "set isnt a table!")

	local properties = set:properties()

	for _, value in properties do
		local read = value.read
		assert(read, "read property doesnt exist!")
		if read ~= valueType then error(`value must be {valueType.tag}!`) end
	end

	return set
end

type function changeMapValues(set: type, valueType: type)
	assert(set:is("table"), "set isnt a table!")

	local newTable = {}
	local properties = set:properties()

	for key, value in properties do
		newTable[key] = valueType
	end

	return types.newtable(newTable)
end

function attributeSet.constructor<T>(data: T)
	local freezed = sift.Dictionary.freezeDeep(data)

	local self = setmetatable({
		_data = freezed,
	}, attributeSet) :: Class<validateMap<T, number>>

	self:onConstruct()

	function self.new()
		local instanceData = {}

		for key, value in pairs(self._data) do
			instanceData[key] = Attribute.constructor(value :: any)
		end

		setmetatable(instanceData, {
			__index = function(t, k)
				local result = rawget(t, k) :: Attribute.Instance?
				assert(result, `{k} value doesnt exist!`) -- maybe use warnings here
				return result:Get()
			end,
		})

		local object = setmetatable({
			data = instanceData,
		}, { __index = self })

		object:onInstanceConstruct()

		return object
	end

	return self
end

function attributeSet.onConstruct<T>(self: T) end
function attributeSet.onInstanceConstruct<T>(self: T) end

local data = {
	test = 123,
}

local test = attributeSet.constructor({
	test = 123,
})

function test.onConstruct(self: Class<typeof(data)>) end

function test.onInstanceConstruct(self: Instance<typeof(data)>) end

local testObj = test.new()

print(testObj.data.test)

return attributeSet
