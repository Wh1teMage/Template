local Actor = require("./Actor")

local service = {}
service.__index = service

type Fields = {
	_actors: { [string]: Actor.Class },
}

type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_actors = {},
	}, service) :: Class

	return self
end

function service.RegisterActor(self: Class, name: string)
	local actorObject = Actor.constructor()
	self._actors[name] = actorObject
	return actorObject
end

function service.GetRegisteredActor(self: Class, name: string)
	return self._actors[name]
end

return service :: Class
