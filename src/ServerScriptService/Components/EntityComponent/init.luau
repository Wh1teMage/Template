local ServerScriptService = game:GetService("ServerScriptService")
local Interfaces = ServerScriptService.Interfaces

local Interface = require(Interfaces.IEntityComponent)
local Modules = require(Interfaces.Modules)

local inject = {
  
}

local component = {} :: Modules.Class<Interface.Main, typeof(inject)>
component.Inject = inject

return {}