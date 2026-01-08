local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Info.Enums)

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

    if (not toBeInjected or #toBeInjected < 1) then return end
    if (not class.Dependencies) then
        class.Dependencies = {}
    end

    warn(`--- {class.Name} was successfully injected! ---`)

    for _, moduleName in toBeInjected do
        local module = self.Elements[moduleName]
        if (not module) then
            warn("Module '" .. moduleName .. "' not found in container")
            continue
        end

        local scope = (module.Scope or Enums.Class.Prototype) :: keyof<typeof(Enums.Class)>

        if (module.Inject and #module.Inject > 0) then self:Inject(module) end

        if (scope == Enums.Class.Singleton) then
            class.Dependencies[moduleName] = module
            continue
        end

        class.Dependencies[moduleName] = module.constructor()
    end
end

function Container.Register(self: Container, name: string, class: InjectedClass)
    local requiredModule = class
    class.Name = name

    local scope = (requiredModule.Scope or Enums.Class.Singleton) :: keyof<typeof(Enums.Class)>

    if (not requiredModule.constructor) then
        if (scope == Enums.Class.Prototype) then warn(`{requiredModule} is a prototype, therefore it must have a constructor!`) end

        requiredModule.constructor = function()
            return requiredModule -- not sure if metatable is better 
        end
    end

    --if (scope == Enums.Class.Singleton) then requiredModule = requiredModule.constructor() end

    self.Elements[name] = requiredModule
end

return Container