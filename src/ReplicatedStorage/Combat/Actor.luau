local sift = require("@Packages/sift")
local actor = {}
actor.__index = actor

type Fields = {
	new: () -> Instance,
}

type InstanceFields = {
	id: string,
	_skillIds: { [string]: boolean },
	_statusIds: { [string]: boolean },
}

export type Class<T = {}> = setmetatable<Fields & T, { __index: typeof(actor) }>
export type Instance<T = {}> = setmetatable<InstanceFields & T, { __index: Class }>

function actor.constructor()
	local self = setmetatable({}, actor) :: Class

	self:onConstruct()

	function self.new()
		local object = setmetatable({}, { __index = self }) :: Instance

		object:onInstanceConstruct()

		return object
	end

	return self
end

function actor.SetSkillId(self: Instance, id: string)
	self._skillIds[id] = true
end
-- ^ separate instance methods from object methods

function actor.GetSkillId(self: Instance, id: string)
	return self._skillIds[id]
end

function actor.GetSkillIds(self: Instance)
	return sift.Dictionary.keys(self._skillIds)
end

function actor.onConstruct(self: Class) end
function actor.onInstanceConstruct(self: Instance) end

return actor
