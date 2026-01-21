local Enums = require("@Info/Enums")
local IPlayerComponent = require('@ServerInterfaces/Classes/IPlayerComponent')
local Modules = require('@ServerInterfaces/Classes/Modules')

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