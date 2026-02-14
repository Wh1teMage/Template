local charm = require("@Packages/charm")
local janitor = require("@Packages/janitor")
local sift = require("@Packages/sift")
local signal = require("@Packages/signal")

local AttributeComponent = require("@Utilities/Components/AttributeComponent")
local ThreadComponent = require("@Utilities/Components/ThreadComponent")
local TimerComponent = require("@Utilities/Components/TimerComponent")
local UtilityComponent = require("@Utilities/Components/UtilityComponent")

local skill = {}
skill.__index = skill

local tags = {
	OnCD = "OnCD",
	Locked = "Locked",
	Interrupted = "Interrupted",

	Idle = "Idle",
	Charging = "Charging",
	Starting = "Starting",
	Ending = "Ending",
}

type Tags = typeof(tags)

type Fields = {
	new: () -> Instance,

	read runContext: "Server" | "Client",
	read name: string,
}

type PrivateInstanceFields = {
	_actorId: string,

	_currentThread: ThreadComponent.Class,
	_cdTimer: TimerComponent.Class,
	_useTimer: TimerComponent.Class,
	_janitor: janitor.Janitor,

	_tags: { [string]: boolean? },
	_tagRuntimeContexts: { [keyof<Tags>]: { Client: boolean, Server: boolean } },
	_tagValidators: { [keyof<Tags>]: { [string]: (self: Instance) -> boolean } },

	_effectIds: { [string]: { id: string, name: string } },
	_attributeSetIds: { [string]: { id: string, name: string } },
}

type PublicInstanceFields = {
	read id: string,

	read cd: AttributeComponent.Instance,
	read duration: AttributeComponent.Instance,

	read tagChanged: signal.Signal<{ tag: keyof<Tags>, state: "Added" | "Removed" }>,
}

export type Class<T = {}> = setmetatable<Fields & T, { __index: typeof(skill) }>
export type Instance<T = {}> = setmetatable<PublicInstanceFields & T, { __index: Class }>

type PrivateInstance<T = {}> = PrivateInstanceFields & Instance<T>

local _validateTag = function(self: PrivateInstance, tag: keyof<Tags>, useValidators: boolean?): boolean
	local runtimeContext = self._tagRuntimeContexts[tag] :: { [string]: boolean }
	local validators = sift.Dictionary.values(self._tagValidators[tag])

	local passed = true
	if not useValidators then return passed end

	if not runtimeContext[self.runContext :: string] then return false end
	passed = sift.Array.every(validators, function(fn)
		return fn(self)
	end)

	return passed
end

local _addTag = function(self: PrivateInstance, tag: keyof<Tags>)
	if self._tags["Locked"] then return end
	if not _validateTag(self, tag, true) then return end
	if self._tags[tag] then return end
	self._tags[tag] = true
	self.tagChanged:Fire({ tag = tag, state = "Added" })
end

local _removeTag = function(self: PrivateInstance, tag: keyof<Tags>)
	if not _validateTag(self, tag, false) then return end
	if self._tags[tag] then return end
	-- ^ maybe separate into another fn?

	self._tags[tag] = nil
	self.tagChanged:Fire({ tag = tag, state = "Removed" })
end

local _combatStateChange = function(self: PrivateInstance, serverFn, clientFn, currentTag, nextTag)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(serverFn, clientFn)

	self._currentThread:Start(function()
		selectedFunction(self)
		_removeTag(self, currentTag)
		_addTag(self, nextTag)
	end)
end

local _chargingTag = function(self: PrivateInstance)
	self._useTimer:Start(self.duration:Get())
	_combatStateChange(self, self.onServerCharge, self.onClientCharge, tags.Charging, tags.Starting)
end

local _startingTag = function(self: PrivateInstance)
	_combatStateChange(self, self.onServerStart, self.onClientStart, tags.Starting, tags.Ending)
end

local _endingTag = function(self: PrivateInstance)
	_combatStateChange(self, self.onServerStop, self.onClientStop, tags.Ending, tags.Idle)
end

local _idleTag = function(self: PrivateInstance)
	self._useTimer:Stop()
end

local _cooldownTag = function(self: PrivateInstance)
	self._cdTimer:Start(self.cd:Get())
end

local _lockTag = function() end

local _interruptedTag = function(self: PrivateInstance)
	_addTag(self, tags.Idle)
	self._currentThread:Stop()
end

local _tagMap = {
	[tags.Charging] = {
		["Added"] = _chargingTag,
	},
	[tags.Starting] = {
		["Added"] = _startingTag,
	},
	[tags.Ending] = {
		["Added"] = _endingTag,
	},
	[tags.OnCD] = {
		["Added"] = _cooldownTag,
	},
	[tags.Locked] = {},
	[tags.Interrupted] = {
		["Added"] = _interruptedTag,
	},
}

type skillData = {
	name: string,
	cd: number,
	duration: number?,
}

function skill.constructor(data: skillData)
	local self = setmetatable({
		name = data.name,
		runContext = UtilityComponent:GetRunContext(),
	}, skill) :: Class

	UtilityComponent:GetBasedOnRuntime(self.onServerConstruct, self.onClientConstruct)(self)

	function self.new()
		local object = setmetatable({
			tagChanged = signal.new(),
			cd = AttributeComponent.constructor(data.cd),
			duration = AttributeComponent.constructor(data.duration or 0),
		}, { __index = self }) :: PrivateInstance

		UtilityComponent:GetBasedOnRuntime(self.onServerInstanceConstruct, self.onClientInstanceConstruct)(object)

		for _, tag in pairs(tags :: { [string]: keyof<Tags> }) do
			object._tagValidators[tag] = {}
		end

		object._tagRuntimeContexts = {
			[tags.Charging] = { Client = true, Server = true },
			[tags.Ending] = { Client = false, Server = true },
			[tags.Idle] = { Client = false, Server = true },
			[tags.Interrupted] = { Client = true, Server = true },
			[tags.OnCD] = { Client = false, Server = true },
			[tags.Locked] = { Client = false, Server = true },
			[tags.Starting] = { Client = false, Server = true },
		}

		object._janitor = janitor.new()
		object._cdTimer = TimerComponent.constructor()
		object._useTimer = TimerComponent.constructor()
		object._currentThread = ThreadComponent.constructor()

		object._janitor:Add(object._cdTimer.finished:Connect(function()
			_removeTag(object, tags.OnCD)
		end))

		object._janitor:Add(object._useTimer.finished:Connect(function()
			_addTag(object, tags.OnCD)
		end))

		object._janitor:Add(object.tagChanged:Connect(function(tagData)
			local selectedTag = _tagMap[tagData.tag]
			if not selectedTag then return end
			if _tagMap[tagData.tag][tagData.state] then selectedTag[tagData.state](object) end
			-- ^ i have no idea why it works like that
		end))

		return object
	end

	return self
end

function skill.ChangeMigration(self: Instance, tag: keyof<Tags>, state: { Client: boolean, Server: boolean })
	self = self :: PrivateInstance
	self._tagRuntimeContexts[tag] = state
end

function skill.AddValidation(self: Instance, tag: keyof<Tags>, name: string, fn: (self: Instance) -> boolean)
	self = self :: PrivateInstance
	self._tagValidators[tag][name] = fn
end

function skill.RemoveValidation(self: Instance, tag: keyof<Tags>, name: string)
	self = self :: PrivateInstance
	self._tagValidators[tag][name] = nil
end

function skill.SetEffect(self: Instance, id: string, name: string)
	self = self :: PrivateInstance
	self._effectIds[id] = { id = id, name = name }
end

function skill.GetEffect(self: Instance, id: string)
	self = self :: PrivateInstance
	return self._effectIds[id]
end

function skill.GetEffects(self: Instance)
	self = self :: PrivateInstance
	return self._effectIds
end

function skill.SetAttributeSet(self: Instance, id: string, name: string)
	self = self :: PrivateInstance
	self._attributeSetIds[id] = { id = id, name = name }
end

function skill.GetAttributeSet(self: Instance, id: string)
	self = self :: PrivateInstance
	return self._attributeSetIds[id]
end

function skill.SetActorId(self: Instance, id: string)
	self = self :: PrivateInstance
	self._actorId = id
end

function skill.GetActorId(self: Instance)
	self = self :: PrivateInstance
	return self._actorId
end

function skill.GetTags(self: Instance)
	self = self :: PrivateInstance
	return self._tags
end

function skill.Interrupt(self: Instance)
	self = self :: PrivateInstance
	_addTag(self, tags.Interrupted)
end

function skill.Start(self: Instance)
	self = self :: PrivateInstance
	_addTag(self, tags.Charging)
end

function skill.Cooldown(self: Instance)
	self = self :: PrivateInstance
	_addTag(self, tags.OnCD)
end

function skill.onServerConstruct<T>(self: T) end
function skill.onServerInstanceConstruct<T>(self: T) end
function skill.onServerInterrupt<T>(self: T) end
function skill.onServerCharge<T>(self: T) end
function skill.onServerStart<T>(self: T) end
function skill.onServerStop<T>(self: T) end

function skill.onClientConstruct<T>(self: T) end
function skill.onClientInstanceConstruct<T>(self: T) end
function skill.onClientInterrupt<T>(self: T) end
function skill.onClientCharge<T>(self: T) end
function skill.onClientStart<T>(self: T) end
function skill.onClientStop<T>(self: T) end

return skill
