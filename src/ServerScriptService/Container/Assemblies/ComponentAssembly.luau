local ServerScriptService = game:GetService("ServerScriptService")

local assembly = {}

for _, module in pairs(ServerScriptService.Components:GetDescendants()) do
    if (not module:IsA('ModuleScript')) then continue end
    assembly[module.Name] = (require)(module)
end

return assembly