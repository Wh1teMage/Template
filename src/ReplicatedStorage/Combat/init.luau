local sift = require("@Packages/sift")
local ActorRegistry = require("@ReplicatedStorage/Combat/ActorRegistry")
local SkillRegistry = require("@ReplicatedStorage/Combat/SkillRegistry")
local EffectExecutionService = require("@self/EffectExecutionService")
local EffectRegistry = require("@self/EffectRegistry")
local ActorInstanceService = require("./Combat/ActorInstanceService")
local SkillExecutionService = require("./Combat/SkillExecutionService")
local combat = {}
combat.__index = combat

type Fields = {
	_actorRegistry: ActorRegistry.Class,
	_skillRegistry: SkillRegistry.Class,
	_effectRegistry: EffectRegistry.Class,

	_actorInstanceService: ActorInstanceService.Class,
	_skillExecutionService: SkillExecutionService.Class,
	_effectExecutionService: EffectExecutionService.Class,
}

type Class = setmetatable<Fields, { __index: typeof(combat) }>

function combat.constructor()
	local self = setmetatable({
		_actorRegistry = ActorRegistry.constructor(),
		_skillRegistry = SkillRegistry.constructor(),
		_effectRegistry = EffectRegistry.constructor(),

		_actorInstanceService = ActorInstanceService.constructor(),
		_skillExecutionService = SkillExecutionService.constructor(),
		_effectExecutionService = EffectExecutionService.constructor(),
	}, combat)

	return self
end

function combat.FindSkillInActor(self: Class, actorId: string, skillName: string)
	local actor = self._actorInstanceService:GetActorById(actorId)
	local actorSkillIds = actor:GetSkillIds()

	local index = sift.Array.findWhere(actorSkillIds, function(skillId)
		local skill = self._skillExecutionService:GetSkillById(skillId)
		return skill.name == skillName
	end)

	return index and self._skillExecutionService:GetSkillById(actorSkillIds[index]) or nil
end

function combat.FindEffectInInstance(self: Class, instanceId: string, effectName: string)
	local actor = self._actorInstanceService:GetActorById(instanceId)
		or self._skillExecutionService:GetSkillById(instanceId)

	local effects = sift.Dictionary.values((actor :: any):GetEffects()) :: { { id: string, name: string } }

	local index = sift.Array.findWhere(effects, function(data)
		return data.name == effectName
	end)

	return index and self._effectExecutionService:GetEffectById(effects[index].id) or nil
end

function combat.FindEffect(self: Class, actorId: string, effectName: string)
	local actor = self._actorInstanceService:GetActorById(actorId) or self._skillExecutionService:GetSkillById(actorId)
	local effect = self:FindEffectInInstance(actorId, effectName)
	assert(effect, `{actor.id} doesnt have a {effectName} effect!`)

	return effect
end

function combat.FindSkill(self: Class, actorId: string, skillName: string)
	local actor = self._actorInstanceService:GetActorById(actorId)
	local skill = self:FindSkillInActor(actorId, skillName)
	assert(skill, `{actor.id} doesnt have a {skillName} skill!`)

	return skill
end

function combat.RegisterSkill(self: Class, data)
	return self._skillRegistry:RegisterSkill(data)
end

function combat.RegisterEffect(self: Class, data)
	return self._effectRegistry:RegisterEffect(data)
end

function combat.RegisterActor(self: Class, name: string)
	return self._actorRegistry:RegisterActor(name)
end

function combat.CreateSkill(self: Class, name: string, actorId: string)
	local skill = self._skillRegistry:GetRegisteredSkill(name)
	local actor = self._actorInstanceService:GetActorById(actorId)

	assert(skill, `{name} skill doesnt have a registered object!`)
	assert(actor, `{actorId} actor doesnt exist!`)

	return self._skillExecutionService:CreateSkill(skill, actor)
end

function combat.CreateEffect(self: Class, name: string, actorId: string)
	local effect = self._effectRegistry:GetRegisteredEffect(name)
	local actor = self._actorInstanceService:GetActorById(actorId) or self._skillExecutionService:GetSkillById(actorId)

	assert(effect, `{name} skill doesnt have a registered object!`)
	assert(actor, `{actorId} actor doesnt exist!`)

	return self._effectExecutionService:CreateEffect(effect, actor)
end

function combat.CreateActor(self: Class, name: string, id: string)
	local actor = self._actorRegistry:GetRegisteredActor(name)
	assert(actor, `{name} actor doesnt have a registered object!`)
	return self._actorInstanceService:CreateActor(actor, id)
end

return combat :: Class
