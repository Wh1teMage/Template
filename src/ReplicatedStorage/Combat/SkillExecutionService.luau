local Skill = require("./Skill")

local service = {}
service.__index = service

type Fields = {
	_skills: { [string]: Skill.Instance },
}

type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_skills = {},
	}, service) :: Class

	return self
end

function service.CreateSkill(self: Class, skill: Skill.Class)
	local id = "1"

	local skillInstance = skill.new()
	self._skills[id] = skillInstance
	return skillInstance
end

function service.GetSkillById(self: Class, id: string)
	return self._skills[id]
end

function service.StartSkill(self: Class, skill: Skill.Instance)
	skill.onServerStart()
end

return service :: Class
