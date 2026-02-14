local Combat = require("../Combat")
local types = require("@ReplicatedStorage/Combat/types")

local actor = Combat:RegisterActor("Default")

type ModifiedClass = types.ActorObject<{
	tag: string,
}>

type ModifiedInstance = types.ActorInstance<{
	stats: {
		test: number,
	},
}>

function actor.onServerConstruct(self: ModifiedClass)
	self.tag = "hi"
end

function actor.onServerInstanceConstruct(self: ModifiedInstance)
	self.stats = {
		test = 123,
	}
end

return actor
