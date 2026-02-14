local Combat = require("../Combat")
local types = require("@ReplicatedStorage/Combat/types")

local skill = Combat:RegisterSkill({
	name = "Test",
	cd = 10,
})

type ModifiedInstance = types.SkillInstance

function skill.onServerCharge(self: ModifiedInstance)
	print("works")
end

return skill
