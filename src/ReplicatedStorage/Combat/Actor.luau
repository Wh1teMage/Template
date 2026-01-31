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

export type Class = setmetatable<Fields, { __index: typeof(actor) }>
export type Instance = setmetatable<InstanceFields, { __index: typeof(actor) }>

function actor.constructor()
	local self = setmetatable({}, actor) :: Class

	function self.new()
		local object = setmetatable({}, { __index = self }) :: Instance

		return object
	end

	return self
end

function actor.SetSkillId(self: InstanceFields, id: string)
	self._skillIds[id] = true
end
-- ^ separate instance methods from object methods

return actor
