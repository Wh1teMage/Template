local Skill = require("./Skill")

local service = {}
service.__index = service

type Fields = {
	_skills: { [string]: Skill.Class },
}

export type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_skills = {},
	}, service) :: Class

	return self
end

function service.RegisterSkill(self: Class, data)
	local skillObject = Skill.constructor(data)
	self._skills[data.name] = skillObject
	return skillObject
end

function service.GetRegisteredSkill(self: Class, name: string)
	return self._skills[name]
end

return service :: Class
