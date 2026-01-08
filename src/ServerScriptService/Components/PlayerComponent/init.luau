local ServerScriptService = game:GetService("ServerScriptService")

local IPlayerComponent = require(ServerScriptService.Interfaces.IPlayerComponent)
local Modules = require(ServerScriptService.Interfaces.Modules)

local inject = {
    Modules.TestComponent,
}

local component = {} :: Modules.Class<IPlayerComponent.Main, typeof(inject)>
component.Inject = inject

function component:test()

end

return {}