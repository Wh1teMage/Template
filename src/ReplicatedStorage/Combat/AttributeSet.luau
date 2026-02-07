local sift = require("@Packages/sift")
local attributeSet = {}
attributeSet.__index = attributeSet

type Fields<T> = {
	new: () -> Instance,
	read _data: T,
}

type InstanceFields<T> = {
	id: string,
	data: T,
}

export type Class<data = {}, T = {}> = setmetatable<Fields<data> & T, { __index: typeof(attributeSet) }>
export type Instance<data = {}> = setmetatable<InstanceFields<data>, { __index: Class }>

function attributeSet.constructor<T>(data: T)
	local freezed = sift.Dictionary.freezeDeep(data)

	local self = setmetatable({
		_data = freezed,
	}, attributeSet) :: Class<T>

	self:onConstruct()

	function self.new()
		local object = setmetatable({
			data = sift.Dictionary.copyDeep(self._data),
		}, { __index = self }) :: Instance

		object:onInstanceConstruct()

		return object
	end

	return self
end

function attributeSet.onConstruct(self: Class) end
function attributeSet.onInstanceConstruct(self: Instance) end

return attributeSet
