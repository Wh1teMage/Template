local RunService = game:GetService("RunService")

local charm = require("@Packages/charm")
local janitor = require("@Packages/janitor")
local signal = require("@Packages/signal")

local component = {}
component.__index = component

local StatesEnum = {
	Active = "Active",
	Paused = "Paused",
	Ended = "Ended",
} :: States

type States = {
	Active: "Active",
	Paused: "Paused",
	Ended: "Ended",
}

type Fields = {
	stateChanged: signal.Signal<{ oldState: keyof<States>?, newState: keyof<States> }>,
	finished: signal.Signal<>,

	_getState: () -> keyof<States>,
	_setState: () -> keyof<States>,

	_janitor: janitor.Janitor,
	_startTime: number,
	_duration: number,
	_passed: number,
}

export type Class = setmetatable<Fields, { __index: typeof(component) }>

local function initialize(self: Class)
	self._janitor:Add(RunService.Heartbeat:Connect(function(dt: number)
		if self._getState() ~= StatesEnum.Active then return end
		self._passed += dt

		if self._passed >= self._duration then self:Stop() end
	end))
end
-- ^ goes against data locality principle, which is kinda bad

function component.constructor()
	local self = setmetatable({
		stateChanged = signal.new(),
		finished = signal.new(),

		_janitor = janitor.new(),
		_startTime = 0,
		_duration = 0,
		_passed = 0,
	}, component) :: Class

	self._getState, self._setState = charm.signal(StatesEnum.Ended)

	charm.listen(self._getState, function(state, previous)
		self.stateChanged:Fire({ newState = state, oldState = previous })
	end)
	-- ^ do i need to clean this?

	initialize(self)

	return self
end

function component.Start(self: Class, duration: number?)
	if self._getState() ~= StatesEnum.Ended then return end

	self._duration = duration or 1e6
	self._passed = 0
	self._startTime = os.clock()

	self._setState(StatesEnum.Active)
end

function component.Stop(self: Class)
	if self._getState() == StatesEnum.Ended then return end
	self.finished:Fire()
	self._setState(StatesEnum.Ended)
end

function component.Pause(self: Class)
	if self._getState() ~= StatesEnum.Active then return end
	self._setState(StatesEnum.Paused)
end

function component.Resume(self: Class)
	if self._getState() ~= StatesEnum.Paused then return end
	self._setState(StatesEnum.Active)
end

function component.AdjustDuration(self: Class, duration: number)
	if self._getState() == StatesEnum.Ended then return end
	self._duration = duration
end

function component.Destroy(self: Class)
	self._janitor:Cleanup()
	-- ^ add more cleanup logic here
end

return component
