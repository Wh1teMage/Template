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

local states = {
	Idle = "Idle",
	OnCD = "OnCD",
	Ending = "Ending",
	Paused = "Paused",
	Charging = "Charging",
	Starting = "Starting",
	Resumed = "Resumed",
	Interrupted = "Interrupted",
} :: States

type States = {
	Idle: "Idle",
	OnCD: "OnCD",
	Paused: "Paused",
	Ending: "Ending",
	Charging: "Charging",
	Starting: "Starting",
	Resumed: "Resumed",
	Interrupted: "Interrupted",
}

type Fields = {
	new: () -> Instance,

	read runContext: "Server" | "Client",
	name: string,
}

type PrivateInstanceFields = {
	_actorId: string,
	_setState: (state: keyof<States>) -> (),
	_getState: () -> keyof<States>,
	_pausedState: keyof<States>?,

	_currentThread: ThreadComponent.Class,
	_cdTimer: TimerComponent.Class,
	_useTimer: TimerComponent.Class,
	_janitor: janitor.Janitor,

	_effectIds: { [string]: { id: string, name: string } },
	_attributeSetIds: { [string]: { id: string, name: string } },

	_stateMigrations: { [keyof<States>]: { [string]: boolean } },
	_stateValidators: { [keyof<States>]: { [string]: (self: Instance) -> boolean } },
}

type PublicInstanceFields = {
	id: string,

	cd: AttributeComponent.Instance,
	duration: AttributeComponent.Instance,

	stateChanged: signal.Signal<{ oldState: keyof<States>?, newState: keyof<States> }>,
}

export type Class<T = {}> = setmetatable<Fields & T, { __index: typeof(skill) }>
export type Instance<T = {}> = setmetatable<PublicInstanceFields & T, { __index: Class }>

type PrivateInstance<T = {}> = PrivateInstanceFields & Instance<T>

local stateMutationMap = {
	[states.Charging] = { states.Idle, states.Resumed },
	[states.Starting] = { states.Charging, states.Resumed },
	[states.Ending] = { states.Starting, states.Resumed },
	[states.Idle] = { states.OnCD, states.Resumed },
	[states.OnCD] = { states.Interrupted, states.Ending },
	[states.Paused] = { states.Charging, states.OnCD, states.Starting, states.Ending },
	[states.Resumed] = { states.Paused },
	[states.Interrupted] = { states.Starting, states.Charging, states.Ending },
}

local _validate = function(self: PrivateInstance, validators: { [string]: (...any) -> boolean }, state: keyof<States>)
	local passed = true
	if stateMutationMap[state] then passed = sift.Array.has(stateMutationMap[state] :: { string }, state) end
	for _, fn in validators do
		if not fn(self) then
			passed = false
			break
		end
	end
	return passed
end

local _serverOnly = function<T>(fn: T)
	return UtilityComponent:GetBasedOnRuntime(fn, function() end)
end

local _setCD = function(self: PrivateInstance)
	if not self.cd then
		warn(`cooldown isnt initialized!`)
		return
	end

	self._useTimer:Stop()
	self._currentThread:Stop()
	self._cdTimer:Start(self.cd:Get())
end

local _interrupt = function(self: PrivateInstance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerInterrupt, self.onClientInterrupt)

	self._setState(states.OnCD)
	selectedFunction(self)
end

local _charge = function(self: PrivateInstance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerCharge, self.onClientCharge)

	self._useTimer:Start(self.duration:Get())

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		self._setState(states.Starting)
	end)
end

local _start = function(self: PrivateInstance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerStart, self.onClientStart)

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		self._setState(states.Ending)
	end)
end

local _stop = function(self: PrivateInstance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerStop, self.onClientStop)

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		self._setState(states.OnCD)
	end)
end

local _pause = function(self: PrivateInstance)
	self._useTimer:Pause()
	self._cdTimer:Pause()
end

local _resume = function(self: PrivateInstance)
	assert(self._pausedState, `pausedState doesnt exist!`)

	self._useTimer:Resume()
	self._cdTimer:Resume()
	self._currentThread:Resume()

	self._setState(self._pausedState)
end

local stateMap = {
	[states.Charging] = _charge,
	[states.Starting] = _start,
	[states.Ending] = _stop,
	[states.Idle] = nil,
	[states.OnCD] = _setCD,
	[states.Paused] = _pause,
	[states.Resumed] = _resume,
	[states.Interrupted] = _interrupt,
}

-- ^ should this one be converted into a FSM?

function skill.constructor(name: string)
	local self = setmetatable({
		name = name,
		runContext = UtilityComponent:GetRunContext(),
	}, skill) :: Class

	UtilityComponent:GetBasedOnRuntime(self.onServerConstruct, self.onClientConstruct)(self)

	function self.new()
		local object = setmetatable({}, { __index = self }) :: PrivateInstance

		UtilityComponent:GetBasedOnRuntime(self.onServerInstanceConstruct, self.onClientInstanceConstruct)(object)

		object.stateChanged = signal.new()

		for _, state in pairs(states :: { [string]: keyof<States> }) do
			object._stateValidators[state] = {}
		end

		object._stateMigrations = {
			[states.Charging] = { Client = true, Server = true },
			[states.Ending] = { Client = false, Server = true },
			[states.Idle] = { Client = false, Server = true },
			[states.Interrupted] = { Client = true, Server = true },
			[states.OnCD] = { Client = false, Server = true },
			[states.Paused] = { Client = false, Server = true },
			[states.Resumed] = { Client = false, Server = true },
			[states.Starting] = { Client = false, Server = true },
		}

		local _getState, _setState = charm.signal(states.Idle :: keyof<States>)

		object._getState = _getState
		object._setState = function(state: keyof<States>)
			local oldState = _getState()
			if not object._stateMigrations[state][object.runContext :: string] then return end
			if not _validate(object, object._stateValidators[oldState], state) then return end
			_setState(state)
		end

		object._janitor = janitor.new()
		object._cdTimer = TimerComponent.constructor()
		object._useTimer = TimerComponent.constructor()
		object._currentThread = ThreadComponent.constructor()

		object._janitor:Add(charm.listen(object._getState, function(state, previous: keyof<States>?)
			if previous == state then return end
			object.stateChanged:Fire({ newState = state, oldState = previous })
		end))

		object._janitor:Add(object._cdTimer.finished:Connect(function()
			object._setState(states.Idle)
		end))

		object._janitor:Add(object._useTimer.finished:Connect(function()
			object._setState(states.OnCD)
		end))

		object._janitor:Add(object.stateChanged:Connect(function(data)
			if data.oldState == states.Resumed then return end
			if stateMap[data.newState] then (stateMap[data.newState] :: (data: PrivateInstance) -> ())(object) end
		end))

		return object
	end

	return self
end

function skill.ChangeMigration(self: Instance, scope: keyof<States>, state: { Client: boolean, Server: boolean })
	self = self :: PrivateInstance
	self._stateMigrations[scope] = state :: { [string]: boolean }
end

function skill.AddValidation(self: Instance, state: keyof<States>, name: string, fn: (self: Instance) -> boolean)
	self = self :: PrivateInstance
	self._stateValidators[state][name] = fn
end

function skill.RemoveValidation(self: Instance, state: keyof<States>, name: string)
	self = self :: PrivateInstance
	self._stateValidators[state][name] = nil
end

function skill.SetData(self: Instance, cd: number, duration: number)
	self = self :: PrivateInstance
	self.cd = AttributeComponent.constructor(cd)
	self.duration = AttributeComponent.constructor(duration)
end

function skill.SetEffect(self: Instance, id: string, name: string)
	self = self :: PrivateInstance
	self._effectIds[id] = { id = id, name = name }
end

function skill.GetEffect(self: Instance, id: string)
	self = self :: PrivateInstance
	return self._effectIds[id]
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

function skill.IsPaused(self: Instance)
	self = self :: PrivateInstance
	return self._getState() == states.Paused
end

function skill.Pause(self: Instance)
	self = self :: PrivateInstance
	self._pausedState = self._getState()
	self._setState(states.Paused)
end

function skill.Resume(self: Instance)
	self = self :: PrivateInstance
	self._setState(states.Resumed)
end

function skill.Interrupt(self: Instance)
	self = self :: PrivateInstance
	self._setState(states.Interrupted)
end

function skill.Start(self: Instance)
	self = self :: PrivateInstance
	self._setState(states.Charging)
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
