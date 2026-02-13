local charm = require("@Packages/charm")
local janitor = require("@Packages/janitor")
local sift = require("@Packages/sift")
local signal = require("@Packages/signal")
local ThreadComponent = require("@Utilities/Components/ThreadComponent")
local TimerComponent = require("@Utilities/Components/TimerComponent")

local effect = {}
effect.__index = effect

local effectType = {
	Instant = "Instant",
	Duration = "Duration",
	Infinite = "Infinite",
} :: EffectType

type EffectType = {
	Instant: "Instant",
	Duration: "Duration",
	Infinite: "Infinite",
}

local states = {
	Idle = "Idle",
	Start = "Start",
	Stop = "Stop",
	Resume = "Resume",
	Pause = "Pause",
} :: States

type States = {
	Idle: "Idle",
	Start: "Start",
	Stop: "Stop",
	Resume: "Resume",
	Pause: "Pause",
}

type Fields = {
	new: () -> Instance,
	name: string,
	type: keyof<EffectType>,
}

type PrivateInstanceFields = {
	_janitor: janitor.Janitor,
	_timer: TimerComponent.Class,
	_currentThread: ThreadComponent.Class,

	_savedState: keyof<States>?,

	_setState: (state: keyof<States>) -> (),
	_getState: () -> keyof<States>,
}

type InstanceFields<T = {}> = {
	id: string,
	object: T,
	effectType: keyof<EffectType>,

	duration: number?,

	_janitor: janitor.Janitor,
	_timer: TimerComponent.Class,
	_currentThread: ThreadComponent.Class,

	_savedState: keyof<States>?,

	_setState: (state: keyof<States>) -> (),
	_getState: () -> keyof<States>,

	stateChanged: signal.Signal<{ newState: keyof<States>, oldState: keyof<States>? }>,
}

export type Class<T = {}> = setmetatable<Fields & T, { __index: typeof(effect) }>
export type Instance<T = {}> = setmetatable<InstanceFields & T, { __index: Class }>

local startBasedOnType = {
	[effectType.Instant] = function(self: Instance)
		self:onStart()
		self._setState(states.Stop)
	end,

	[effectType.Duration] = function(self: Instance)
		self:onStart()
		self._currentThread:Start(function()
			task.wait(self.duration or 5)
			if self._getState() == states.Pause then self._currentThread:Pause() end
			self._setState(states.Stop)
		end)
	end,

	[effectType.Infinite] = function(self: Instance)
		self:onStart()
	end,
}

local stopBasedOnType = {
	[effectType.Instant] = function(self: Instance)
		self:onStop()
	end,

	[effectType.Duration] = function(self: Instance)
		self:onStop()
	end,

	[effectType.Infinite] = function(self: Instance)
		self:onStop()
	end,
}

local function _start(self: Instance)
	startBasedOnType[self.type](self)
end

local function _stop(self: Instance)
	stopBasedOnType[self.type](self)
end

local function _pause(self: Instance)
	if not sift.Array.has({ states.Start }, self._getState()) then return end

	self._savedState = self._getState()

	self._currentThread:Pause()
	self._setState(states.Pause)
end

local function _resume(self: Instance)
	if not sift.Array.has({ states.Pause }, self._getState()) then return end

	self._currentThread:Pause()
	self._setState(states.Resume)
end

local function _postResume(self: Instance)
	if not sift.Array.has({ states.Resume }, self._getState()) then return end
	assert(self._savedState, `saved State hasnt been found!`)

	self._currentThread:Resume()
	self._setState(self._savedState)

	self._savedState = nil
end

local stateMap = {
	[states.Idle] = function(self: Instance) end,
	[states.Resume] = function(self: Instance)
		_postResume(self)
	end,
	[states.Pause] = function(self: Instance) end,
	[states.Start] = function(self: Instance)
		_start(self)
	end,
	[states.Stop] = function(self: Instance)
		_stop(self)
	end,
}

function effect.constructor(name: string)
	local self = setmetatable({
		name = name,
	}, effect) :: Class

	self:onConstruct()

	function self.new<T>(parent: T)
		local object = setmetatable({
			object = parent,
		}, { __index = self }) :: Instance

		object:onInstanceConstruct()

		object._getState, object._setState = charm.signal(states.Idle)

		object._timer = TimerComponent.constructor()
		object._currentThread = ThreadComponent.constructor()

		object.stateChanged = signal.new()

		object._janitor:Add(charm.listen(object._getState, function(state, previous)
			object.stateChanged:Fire({ newState = state, oldState = previous })
		end))

		object.stateChanged:Connect(function(data)
			if data.oldState == states.Resume then return end
			if stateMap[data.newState] then stateMap[data.newState](object) end
		end)

		return object
	end

	return self
end

function effect.onStart<T>(self: T) end
function effect.onStop<T>(self: T) end

function effect.onConstruct<T>(self: T) end
function effect.onInstanceConstruct<T>(self: T) end

function effect.Start(self: Instance)
	self._setState(states.Start)
end

function effect.Stop(self: Instance)
	self._setState(states.Stop)
end

function effect.Pause(self: Instance)
	_pause(self)
end

function effect.Resume(self: Instance)
	_resume(self)
end

return effect
