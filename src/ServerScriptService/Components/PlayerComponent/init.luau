local Enums = require("@Info/Enums")
local IPlayerComponent = require('@ServerInterfaces/Classes/IPlayerComponent')
local Modules = require('@ServerInterfaces/Classes/Modules')

local inject = {
    Modules.TestComponent,
}

local component = {} :: Modules.Class<IPlayerComponent.Main, typeof(inject)>

return component