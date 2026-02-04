local charm = require("@Packages/charm")
local janitor = require("@Packages/janitor")
local sift = require("@Packages/sift")
local signal = require("@Packages/signal")
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
} :: States

type States = {
	Idle: "Idle",
	OnCD: "OnCD",
	Paused: "Paused",
	Ending: "Ending",
	Charging: "Charging",
	Starting: "Starting",
}

type Fields = {
	new: () -> Instance,

	duration: number,
	cd: number,

	name: string,
}

type InstanceFields = {
	id: string,

	_actorId: string,
	_setState: (state: keyof<States>) -> (),
	_getState: () -> keyof<States>,
	_pausedState: keyof<States>?,

	_currentThread: ThreadComponent.Class,
	_cdTimer: TimerComponent.Class,
	_useTimer: TimerComponent.Class,
	_janitor: janitor.Janitor,

	_chargeValidators: { [string]: (self: Instance) -> boolean },
	_startValidators: { [string]: (self: Instance) -> boolean },
	_stopValidators: { [string]: (self: Instance) -> boolean },
	_interruptValidators: { [string]: (self: Instance) -> boolean },

	stateChanged: signal.Signal<{ oldState: keyof<States>?, newState: keyof<States> }>,
}
-- ^ add more signals

export type Class<T = {}> = setmetatable<Fields & T, { __index: typeof(skill) }>
export type Instance<T = {}> = setmetatable<InstanceFields & T, { __index: Class }>

local _validate = function(self: Instance, validationStates: { keyof<States> }, validators: { [string]: (...any) -> boolean })
	if sift.Array.has(validationStates, self._getState()) then return false end
	for _, fn in validators do
		if not fn(self) then return false end
	end
	return true
end

local _serverOnly = function<T>(fn: T)
	return UtilityComponent:GetBasedOnRuntime(fn, function() end)
end

local _validateCharge = function(self: Instance)
	if not _validate then return false end
	return _validate(self, { states.Charging }, self._chargeValidators)
end

local _validateStart = function(self: Instance)
	if not _validate then return false end
	return _validate(self, { states.Starting }, self._startValidators)
end

local _validateStop = function(self: Instance)
	if not _validate then return false end
	return _validate(self, { states.Ending }, self._stopValidators)
end

local _validateInterrupt = function(self: Instance)
	if not _validate then return false end
	return _validate(self, { states.Starting, states.Charging, states.Ending }, self._interruptValidators)
end

local _setCD = function(self: Instance)
	self._useTimer:Stop()
	self._currentThread:Stop()
	self._cdTimer:Start(self.cd)
end

local _interrupt = function(self: Instance)
	if not _validateInterrupt(self) then return end
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerInterrupt, self.onClientInterrupt)

	self._setState(states.OnCD)
	selectedFunction(self)
end

local _charge = function(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerCharge, self.onClientCharge)
	if not _validateCharge(self) then return end

	self._useTimer:Start(self.duration)

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		_serverOnly(self._setState)(states.Starting)
	end)
end

local _start = function(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerStart, self.onClientStart)
	if not _validateStart(self) then return end

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		_serverOnly(self._setState)(states.Ending)
	end)
end

local _stop = function(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerStop, self.onClientStop)
	if not _validateStop then return end

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		self._setState(states.OnCD)
	end)
end

local stateMap = {
	[states.Charging] = _charge,
	[states.Starting] = _start,
	[states.Ending] = _stop,
	[states.Idle] = nil,
	[states.OnCD] = _setCD,
	[states.Paused] = nil,
}

function skill.constructor(name: string)
	local self = setmetatable({
		name = name,
	}, skill) :: Class

	function self.new()
		local object = setmetatable({}, { __index = self }) :: Instance

		object.stateChanged = signal.new()

		object._getState, object._setState = charm.signal(states.Idle :: keyof<States>)

		object._janitor = janitor.new()
		object._cdTimer = TimerComponent.constructor()
		object._useTimer = TimerComponent.constructor()
		object._currentThread = ThreadComponent.constructor()

		object._janitor:Add(charm.listen(object._getState, function(state, previous)
			object.stateChanged:Fire({ newState = state, oldState = previous })
		end))

		object._janitor:Add(object._cdTimer.finished:Connect(function()
			object._setState(states.Idle)
		end))

		object._janitor:Add(object._useTimer.finished:Connect(function()
			object._setState(states.OnCD)
			object._cdTimer:Start(self.duration)
		end))

		object._janitor:Add(object.stateChanged:Connect(function(data)
			if data.oldState == states.Paused then return end
			if stateMap[data.newState] then (stateMap[data.newState] :: () -> ())(object) end
		end))

		return object
	end

	return self
end

function skill.SetActorId(self: Instance, id: string)
	self._actorId = id
end

function skill.GetActorId(self: Instance)
	return self._actorId
end

function skill.IsPaused(self: Instance)
	return self._getState() == states.Paused
end

-- state change -> pause (not as method)
function skill.Pause(self: Instance)
	self._pausedState = self._getState()

	self._useTimer:Pause()
	self._cdTimer:Pause()
	self._setState(states.Paused)
end

function skill.Resume(self: Instance)
	assert(self._pausedState, `skill was resumed without pausing!`)
	self._setState(self._pausedState)

	self._useTimer:Resume()
	self._cdTimer:Resume()
	self._currentThread:Resume()
end
function skill.Interrupt(self: Instance)
	_interrupt(self)
end

function skill.Start(self: Instance)
	self._setState(states.Charging)
end

function skill.onServerInterrupt(self: Instance) end
function skill.onClientInterrupt(self: Instance) end
function skill.onServerCharge(self: Instance) end
function skill.onClientCharge(self: Instance) end
function skill.onServerStart(self: Instance) end
function skill.onClientStart(self: Instance) end
function skill.onServerStop(self: Instance) end
function skill.onClientStop(self: Instance) end

return skill
