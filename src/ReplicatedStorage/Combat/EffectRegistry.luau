local Effect = require("./StatusEffect")

local service = {}
service.__index = service

type Fields = {
	_effects: { [string]: Effect.Class },
}

export type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_effects = {},
	}, service) :: Class

	return self
end

function service.RegisterEffect(self: Class, data)
	local skillObject = Effect.constructor(data)
	self._effects[data.name] = skillObject
	return skillObject
end

function service.GetRegisteredEffect(self: Class, name: string)
	return self._effects[name]
end

return service :: Class
