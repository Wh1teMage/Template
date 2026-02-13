local sift = require("@Packages/sift")
local actor = {}
actor.__index = actor

type Fields = {
	new: () -> Instance,
}

type InstanceFields = {
	id: string,
	_skillIds: { [string]: { id: string, name: string } },
	_effectIds: { [string]: { id: string, name: string } },
	_attributeSetIds: { [string]: { id: string, name: string } },
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

function actor.SetEffect(self: Instance, id: string, name: string)
	self._effectIds[id] = { id = id, name = name }
end

function actor.GetEffect(self: Instance, id: string)
	return self._effectIds[id]
end

function actor.SetAttributeSet(self: Instance, id: string, name: string)
	self._attributeSetIds[id] = { id = id, name = name }
end

function actor.GetAttributeSet(self: Instance, id: string)
	return self._attributeSetIds[id]
end

function actor.SetSkill(self: Instance, id: string, name: string)
	self._skillIds[id] = { id = id, name = name }
end

function actor.GetSkillId(self: Instance, id: string)
	return self._skillIds[id]
end

function actor.GetSkillIds(self: Instance)
	return sift.Dictionary.keys(self._skillIds)
end

function actor.onConstruct(self: Class) end
function actor.onInstanceConstruct(self: Instance) end

return actor
