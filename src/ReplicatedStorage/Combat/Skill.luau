local skill = {}
skill.__index = skill

type Fields = {
	new: () -> Instance,
}

type InstanceFields = {
	id: string,
}

export type Class = setmetatable<Fields, { __index: typeof(skill) }>
export type Instance = setmetatable<InstanceFields, { __index: typeof(skill) }>

function skill.constructor()
	local self = setmetatable({}, skill) :: Class

	function self.new()
		local object = setmetatable({}, { __index = self }) :: Instance

		return object
	end

	return self
end

function skill.onServerStart() end
function skill.onClientStart() end
function skill.onServerEnd() end
function skill.onClientEnd() end

return skill
