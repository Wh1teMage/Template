local UtilityComponent = require("@Utilities/Components/UtilityComponent")
local Actor = require("./Actor")

local service = {}
service.__index = service

type Fields = {
	_actors: { [string]: Actor.Instance },
}

export type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_actors = {},
	}, service) :: Class

	return self
end

function service.CreateActor(self: Class, actor: Actor.Class, id: string)
	local actorInstance = actor.new()
	self._actors[id] = actorInstance
	return actorInstance
end

function service.GetActorById(self: Class, id: string)
	return self._actors[id]
end

return service :: Class
