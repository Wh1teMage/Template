local Modules = require("@ServerInterfaces/Classes/Modules")

type Fields = {}

local component = {}
component.Name = Modules.TestComponent
component.Inject = {}

type Class = Modules.Class<typeof(component), Fields>

function component.test(self: Class)
	print("hi")
	return "hello"
end
-- ^ fix bug if self isnt presented

return component :: Modules.Validate<typeof(component), Class>
