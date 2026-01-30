local Enums = require("@Info/Enums")
local ITestComponentCopy = require('@ServerInterfaces/Classes/ITestComponentCopy')
local Modules = require('@ServerInterfaces/Classes/Modules')
local ComponentUtilities = require("@Utilities/Functions/ComponentUtilities")



local template = ComponentUtilities.CreateComponent({Modules.TestComponent}, Enums.Class.Prototype)
type Class = Modules.Class<ITestComponentCopy.Main, typeof(template.Inject)>

local component = {} :: Class

function component.test(self: Class)
    self.Dependencies.TestComponent.sayHello()
    return nil
end

function component.constructor()
        
end

return setmetatable({}, { __index = component })