local UtilityComponent = require("@Utilities/Components/UtilityComponent")
local Actor = require("./Actor")
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

function service.CreateSkill(self: Class, skill: Skill.Class, actor: Actor.Instance)
	local id = tostring(UtilityComponent:GenerateId())

	local skillInstance = skill.new()
	skillInstance:SetActorId(id)

	self._skills[id] = skillInstance
	return skillInstance
end

function service.GetSkillById(self: Class, id: string)
	return self._skills[id]
end

function service.StartSkill(self: Class, skill: Skill.Instance, actor: Actor.Instance)
	assert(actor:GetSkillId(skill.id), `{actor.id} doesnt have a {skill.name} skill!`)
	skill:Charge()
end

function service.InterruptSkill(self: Class, skill: Skill.Instance, actor: Actor.Instance)
	assert(actor:GetSkillId(skill.id), `{actor.id} doesnt have a {skill.name} skill!`)
	skill:Interrupt()
end

return service :: Class
