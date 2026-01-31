local Skill = require("./Skill")

local service = {}
service.__index = service

type Fields = {
	_skills: { [string]: Skill.Class },
}

type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_skills = {},
	}, service) :: Class

	return self
end

function service.RegisterSkill(self: Class, name: string)
	local skillObject = Skill.constructor()
	self._skills[name] = skillObject
	return skillObject
end

function service.GetRegisteredSkill(self: Class, name: string)
	return self._skills[name]
end

return service
