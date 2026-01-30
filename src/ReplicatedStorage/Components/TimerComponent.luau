local types = require("@Utilities/Signal/types")

local component = {}
component.__index = component

type States = {
    Active: 'Active',
    Paused: 'Paused',
    Ended: 'Ended'
}

local stateChanged

type Fields = {
    StateChanged: types.BindableScope<>,
    Finished: any,

    _startTime: number,
    _duration: number,
    _passed: number,
}

type IComponent = typeof(component) & Fields

function component.constructor()
    local self = setmetatable({

    }, component)
    return self
end

function component.Start(self: IComponent)
    self._startTime = os.clock()
end

function component.Stop(self: IComponent)
    
end

function component.Pause(self: IComponent)
    
end

function component.Resume(self: IComponent)
    
end

function component.Adjust(self: IComponent)
    
end

return component