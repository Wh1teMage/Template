local UtilityComponent = require("@Utilities/Components/UtilityComponent")

local StatusEffect = require("./StatusEffect")

local service = {}
service.__index = service

type Fields = {
	_effects: { [string]: StatusEffect.Instance },
}

export type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_effects = {},
	}, service) :: Class

	return self
end

function service.CreateEffect<T>(self: Class, effect: StatusEffect.Class, actor: T)
	local id = tostring(UtilityComponent:GenerateId())
	local effectInstance = effect.new(actor)

	self._effects[id] = effectInstance
	return effectInstance
end

function service.GetEffectById(self: Class, id: string)
	return self._effects[id]
end

return service :: Class
