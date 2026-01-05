local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = require(ServerScriptService.Container.Interfaces.Modules)
local ContainerTypes = require(ReplicatedStorage.Utilities.Container.ContainerTypes)

local inject = {
    Modules.ITestComponentcopy,
    Modules.TestComponent
}

local component = {} :: ContainerTypes.InjectedClass<typeof(inject), ContainerTypes.filterModuleTypes<Modules.Types, typeof(inject)>>
component.Inject = inject

return component