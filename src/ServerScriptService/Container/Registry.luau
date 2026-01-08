local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PackageAssembly = require(ReplicatedStorage.Container.Assemblies.PackageAssembly)
local Container = require(ReplicatedStorage.Utilities.Container)

local Assemblies = ServerScriptService.Container.Assemblies

return function()
    local container = Container.new()

    local assemblies: {{[string]: any}} = {}

    for _, assemblyModule in Assemblies:GetChildren() do
        local assembly = (require)(assemblyModule)
        table.insert(assemblies, assembly)
    end

    table.insert(assemblies, PackageAssembly)

    for _, assembly in pairs(assemblies) do
        for name, class in pairs(assembly) do
            container:Register(name, class)
        end
    end

    for _, assembly in pairs(assemblies) do
        for name, class in pairs(assembly) do
            container:Inject(class)
        end
    end

    return container
end
