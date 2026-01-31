local ActorInstanceService = require("@ReplicatedStorage/Combat/ActorInstanceService")
local SkillExecutionService = require("@ReplicatedStorage/Combat/SkillExecutionService")
local combat = {}
combat.__index = combat

type Fields = {}
type Class = setmetatable<Fields, { __index: typeof(combat) }>

function combat.constructor()
	local self = setmetatable({}, combat)

	return self
end

function combat.StartSkill(self: Class, actorId: string, skillId: string)
	local actor = ActorInstanceService:GetActorById(actorId)
	local skill = SkillExecutionService:GetSkillById(skillId)
end

return combat
