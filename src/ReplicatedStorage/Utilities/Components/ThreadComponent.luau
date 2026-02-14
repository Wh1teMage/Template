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
	_setState: (keyof<States>) -> (),

	_janitor: janitor.Janitor,
	_currentThead: thread,
}

export type Class = setmetatable<Fields, { __index: typeof(component) }>

function component.constructor()
	local self = setmetatable({
		stateChanged = signal.new(),
		finished = signal.new(),

		_janitor = janitor.new(),
	}, component) :: Class

	self._getState, self._setState = charm.signal(StatesEnum.Ended)

	charm.listen(self._getState, function(state, previous)
		self.stateChanged:Fire({ newState = state, oldState = previous })
	end)

	return self
end

function component.Start(self: Class, fn: (...any) -> ...any)
	if self._getState() ~= StatesEnum.Ended then return end
	self._currentThead = coroutine.wrap(fn)()
	self._setState(StatesEnum.Active)
end

function component.Stop(self: Class)
	if self._getState() == StatesEnum.Ended then return end
	coroutine.close(self._currentThead)
	self.finished:Fire()
	self._setState(StatesEnum.Ended)
end

function component.Pause(self: Class)
	if self._getState() ~= StatesEnum.Active then return end
	self._setState(StatesEnum.Paused)
	coroutine.yield()
end

function component.Resume(self: Class)
	if self._getState() ~= StatesEnum.Paused then return end
	coroutine.resume(self._currentThead)
	self._setState(StatesEnum.Active)
end

function component.Destroy(self: Class)
	self._janitor:Cleanup()
	-- ^ add more cleanup logic here
end

return component
