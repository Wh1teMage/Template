local Actor = require("@ReplicatedStorage/Combat/Actor")
local Skill = require("@ReplicatedStorage/Combat/Skill")

export type ActorObject<T = {}> = Actor.Class<T>
export type ActorInstance<T = {}> = Actor.Instance<T>

export type SkillObject<T = {}> = Skill.Class<T>
export type SkillInstance<T = {}> = Skill.Instance<T>

return {}
