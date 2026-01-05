local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Container.Registry)

local container = Registry()

print(container.Elements)