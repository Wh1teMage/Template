local sift = require("@Packages/sift")
local ActorRegistry = require("@ReplicatedStorage/Combat/ActorRegistry")
local SkillRegistry = require("@ReplicatedStorage/Combat/SkillRegistry")
local ActorInstanceService = require("./Combat/ActorInstanceService")
local SkillExecutionService = require("./Combat/SkillExecutionService")
local combat = {}
combat.__index = combat

type Fields = {}
type Class = setmetatable<Fields, { __index: typeof(combat) }>

function combat.constructor()
	local self = setmetatable({}, combat)

	return self
end

function combat.FindSkillInActor(self: Class, actorId: string, skillName: string)
	local actor = ActorInstanceService:GetActorById(actorId)
	local actorSkillIds = actor:GetSkillIds()

	local index = sift.Array.findWhere(actorSkillIds, function(skillId)
		local skill = SkillExecutionService:GetSkillById(skillId)
		return skill.name == skillName
	end)

	return index and SkillExecutionService:GetSkillById(actorSkillIds[index]) or nil
end

function combat.StartSkill(self: Class, actorId: string, skillName: string)
	local actor = ActorInstanceService:GetActorById(actorId)
	local skill = self:FindSkillInActor(actorId, skillName)
	assert(skill, `{actor.id} doesnt have a {skillName} skill!`)

	SkillExecutionService:StartSkill(skill, actor)
end

function combat.InterruptSkill(self: Class, actorId: string, skillName: string)
	local actor = ActorInstanceService:GetActorById(actorId)
	local skill = self:FindSkillInActor(actorId, skillName)
	assert(skill, `{actor.id} doesnt have a {skillName} skill!`)

	SkillExecutionService:InterruptSkill(skill, actor)
end

function combat.RegisterSkill(self: Class, name: string)
	return SkillRegistry:RegisterSkill(name)
end

function combat.RegisterActor(self: Class, name: string)
	return ActorRegistry:RegisterActor(name)
end

function combat.CreateSkill(self: Class, name: string, actorId: string)
	local skill = SkillRegistry:GetRegisteredSkill(name)
	local actor = ActorInstanceService:GetActorById(actorId)

	assert(skill, `{name} skill doesnt have a registered object!`)
	assert(actor, `{actorId} actor doesnt exist!`)

	return SkillExecutionService:CreateSkill(skill, actor)
end

function combat.CreateActor(self: Class, name: string, id: string)
	local actor = ActorRegistry:GetRegisteredActor(name)
	assert(actor, `{name} actor doesnt have a registered object!`)
	return ActorInstanceService:CreateActor(actor, id)
end

return combat :: Class
