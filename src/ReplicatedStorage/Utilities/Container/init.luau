local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require("@Info/Enums")
local sift = require("@Packages/sift")

local ContainerTypes = require("@self/types")

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

	if class.Injected then
		warn(`{class.Name} was already injected!`)
		return
	end

	class.Injected = true

	if not toBeInjected or #toBeInjected < 1 then return end
	if not class.Dependencies then class.Dependencies = {} end

	if not class.constructor then
		warn(`{class.Name} must have a constructor!`)
		return
	end
	local object = class.constructor()

	for _, moduleName in toBeInjected do
		local module = self.Elements[moduleName]
		if not module then
			warn("Module '" .. moduleName .. "' not found in container") -- nah, id win
			continue
		end

		if module.Inject and #module.Inject > 0 then self:Inject(module) end
		if not module.constructor then
			warn(`{module.Name} must have a constructor!`)
			continue
		end

		object.Dependencies[moduleName] = module.constructor()
	end
end

function Container.Start(self: Container)
	if not self.registered then
		warn(`Container has no registered classes!`)
		return
	end

	for _, element in pairs(self.Elements) do
		if element.Injected then continue end
		self:Inject(element)
	end

	local filtered = sift.Dictionary.filter(self.Elements, function(value: InjectedClass, key: string)
		return value.Scope == Enums.Class.Service
	end)

	local services: { InjectedClass } = sift.Dictionary.values(filtered)
	local sorted: { InjectedClass } = sift.Array.sort(services, function(firstValue: InjectedClass, secondValue: InjectedClass)
		return firstValue.Priority > secondValue.Priority
	end)

	for _, service in sorted do
		if not service.start then
			warn(`{service.Name} is a service, therefore it must have a start() method!`)
			continue
		end
		task.spawn(function()
			warn(`--- {service.Name} started successfully! ---`)
			service.start()
		end)
		service.Initialized = true
	end
end

function Container.RegisterDirectory(self: Container, dir: Instance)
	for _, moduleScript in pairs(dir:GetDescendants()) do
		if not moduleScript:IsA("ModuleScript") then continue end

		local requiredModule = (require)(moduleScript)
		if type(requiredModule) ~= "table" then continue end

		self:RegisterModule(moduleScript.Name, requiredModule)
	end

	self.registered = true
end

function Container.RegisterModule(self: Container, name: string, class: InjectedClass)
	class.Name = name

	class.Injected = false
	class.Initialized = false
	class.Priority = class.Priority or 1
	class.Scope = class.Scope or Enums.Class.Singleton

	--local scope = (class.Scope or Enums.Class.Singleton) :: keyof<typeof(Enums.Class)>

	if class.Scope == Enums.Class.Service and not class.start then
		warn(`{class.Name} is a service, therefore it must have a start() method!`)
	end

	if not class.constructor then
		if class.Scope == Enums.Class.Prototype then
			warn(`{class.Name} is a prototype, therefore it must have a constructor!`)
		end

		class.constructor = function()
			return class
		end
	end

	self.Elements[name] = class
end

return Container
