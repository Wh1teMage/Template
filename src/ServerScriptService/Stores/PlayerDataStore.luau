local Interface = require('@ServerInterfaces/Classes/IPlayerDataStore')
local Modules = require('@ServerInterfaces/Classes/Modules')

local inject = {
  
}

local component = {} :: Modules.Class<Interface.Main, typeof(inject)>
component.Inject = inject

function component.constructor()
    local self = setmetatable({}, {
        __index = component
    })

    self.values = {}

    return self
end

function component:AddPlayer(playerData, name)
    self.values[name] = playerData
end

function component:RemovePlayer(name)
    local selectedPlayer = self:GetPlayer(name)
    self.values[name] = nil -- add proper destroy here
    return selectedPlayer
end

function component:GetPlayer(name)
    return self.values[name]
end

function component:GetPlayers()
    return self.values
end

return component