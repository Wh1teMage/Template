local charm = require("@Packages/charm")
local janitor = require("@Packages/janitor")
local signal = require("@Packages/signal")
local ThreadComponent = require("@Utilities/Components/ThreadComponent")
local TimerComponent = require("@Utilities/Components/TimerComponent")
local UtilityComponent = require("@Utilities/Components/UtilityComponent")

local skill = {}
skill.__index = skill

local states = {
	Idle = "Idle",
	Paused = "Paused",
	Charging = "Charging",
	Starting = "Starting",
	Ending = "Ending",
	OnCD = "OnCD",
} :: States

type States = {
	Idle: "Idle",
	Paused: "Paused",
	Charging: "Charging",
	Starting: "Starting",
	Ending: "Ending",
	OnCD: "OnCD",
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

	stateChanged: signal.Signal<{ oldState: keyof<States>?, newState: keyof<States> }>,
}
-- ^ add more signals

export type Class<T = {}> = setmetatable<Fields & T, { __index: typeof(skill) }>
export type Instance<T = {}> = setmetatable<InstanceFields & T, { __index: Class }>

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

function skill.CanBeCharged(self: Instance)
	if self._getState() ~= states.Idle then return false end
	if not self:canChargeHook() then return false end
	return true
end

function skill.CanBeStarted(self: Instance)
	if self._getState() ~= states.Charging then return false end
	if not self:canStartHook() then return false end
	return true
end

function skill.CanBeStopped(self: Instance)
	if self._getState() ~= states.Starting then return false end
	if not self:canStopHook() then return false end
	return true
end

function skill.IsPaused(self: Instance)
	return self._getState() == states.Paused
end

function skill.Interrupt(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerInterrupt, self.onClientInterrupt)
	self._useTimer:Stop()
	self._currentThread:Stop()
	selectedFunction(self)
end

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

function skill.Charge(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerCharge, self.onClientCharge)
	if not self:CanBeCharged() then return end

	self._useTimer:Start(self.duration)

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		self:Start()
	end)
end

function skill.Start(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerStart, self.onClientStart)
	if not self:CanBeStarted() then return end

	self._currentThread:Start(function()
		selectedFunction(self)
		if self:IsPaused() then self._currentThread:Pause() end
		self:Stop()
	end)
end

function skill.Stop(self: Instance)
	local selectedFunction = UtilityComponent:GetBasedOnRuntime(self.onServerStop, self.onClientStop)
	if not self:CanBeStopped() then return end

	self._currentThread:Start(function()
		selectedFunction(self)
		self:Interrupt()
	end)
end

function skill.canStartHook(self: Instance)
	return true
end

function skill.canChargeHook(self: Instance)
	return true
end

function skill.canStopHook(self: Instance)
	return true
end

function skill.onServerInterrupt(self: Instance) end
function skill.onClientInterrupt(self: Instance) end
function skill.onServerCharge(self: Instance) end
function skill.onClientCharge(self: Instance) end
function skill.onServerStart(self: Instance) end
function skill.onClientStart(self: Instance) end
function skill.onServerStop(self: Instance) end
function skill.onClientStop(self: Instance) end

return skill :: Class
