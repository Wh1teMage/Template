local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Enums = require(ReplicatedStorage.Info.Enums)

local ITestComponentCopy = require(ServerScriptService.Interfaces.ITestComponentCopy)
local Modules = require(ServerScriptService.Interfaces.Modules)

local inject = {
    Modules.TestComponent
}

local component = {} :: Modules.Class<ITestComponentCopy.Main, typeof(inject)>
component.Inject = inject

function component:test()
    print(component)
    component.Dependencies.TestComponent.sayHello()

    return nil
end

return component