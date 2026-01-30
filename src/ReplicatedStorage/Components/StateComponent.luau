local signal = require("@Packages/signal")

local component = {}
component.__index = component

type Fields = {
    state: any,
    StateChanged: signal.Signal<{oldState: any, newState: any}>
}

type Class = typeof(component) & Fields

function component.constructor(initial)
    local self = setmetatable({
        StateChanged = signal.new(),
        state = initial
    }, component)

    return self
end

function component.setState(self: Class, newState: any)
    local oldState = self.state
    self.state = newState
    self.StateChanged:Fire({oldState = oldState, newState = newState})
end

return component