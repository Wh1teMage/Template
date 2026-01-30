local fabric = {}

local component = {}
component.__index = component

type IComponent = typeof(component)

function component.constructor()
    local self = setmetatable({}, component)
    return self
end

function component.start(self: IComponent)
    
end

function component.pause(self: IComponent)
    
end

function component.adjust(self: IComponent)
    
end

function fabric.newTimer()
    
end

return fabric