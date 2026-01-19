local ServerScriptService = game:GetService("ServerScriptService")

local Enums = require("@Info/Enums")
local IPlayerComponent = require(ServerScriptService.Interfaces.IPlayerComponent)
local Modules = require(ServerScriptService.Interfaces.Modules)

local inject = {
    Modules.TestComponent,
}

local component = {} :: Modules.Class<IPlayerComponent.Main, typeof(inject)>
component.Inject = inject
component.Scope = Enums.Class.Service

function component:test()

end

function component.start()
    print('started!')
end
    
return component