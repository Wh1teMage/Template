local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContainerTypes = require(script.types)

local Container = {}
Container.__index = Container

type Container = ContainerTypes.Container
type InjectedClass = ContainerTypes.InjectedClass<any>

function Container.new()
    local self = setmetatable({
        Elements = {},
    }, Container)
    return self :: Container
end

function Container.Inject(self: Container, class: InjectedClass)
    local toBeInjected = class.Inject

    if (not toBeInjected) then return end
    if (not class.Dependencies) then
        class.Dependencies = {}
    end

    for _, moduleName in toBeInjected do
        local module = self.Elements[moduleName]
        if (not module) then
            warn("Module '" .. moduleName .. "' not found in container")
            continue
        end

        local scope = (module.Scope or "Prototype") :: "Singleton" | "Prototype"

        if (module.Inject and #module.Inject > 0) then self:Inject(module) end

        if (scope == "Singleton") then
            class.Dependencies[moduleName] = module
            continue
        end

        class.Dependencies[moduleName] = module.constructor()
    end
end

function Container.Register(self: Container, name: string, class: InjectedClass)
    local requiredModule = class

    local scope = (requiredModule.Scope or "Prototype") :: "Singleton" | "Prototype"
    local object;

    if (not requiredModule.constructor) then
        requiredModule.constructor = function()
            return setmetatable({}, { __index = requiredModule })
        end
    end

    object = requiredModule.constructor()
    if (scope == "Singleton") then requiredModule = object end

    self.Elements[name] = requiredModule
end

return Container