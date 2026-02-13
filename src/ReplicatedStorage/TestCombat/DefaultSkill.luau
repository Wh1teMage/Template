local Combat = require("@ReplicatedStorage/Combat")
local types = require("@ReplicatedStorage/Combat/types")

local skill = Combat:RegisterSkill("Test")

type ModifiedInstance = types.SkillInstance

function skill.onServerCharge(self: ModifiedInstance)
	print("works")
end

return skill
