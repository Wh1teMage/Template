local Modules = require("@ServerInterfaces/Classes/Modules")

type Fields = {}

local component = {}
component.Name = Modules.TestComponentCopy
component.Inject = {
	Modules.TestComponent,
}

type Class = Modules.Class<typeof(component), Fields>

function component.hi() end

function component.test123(self: Class, num: number)
	print(self.Dependencies.TestComponent.test())
	return nil
end

return component :: Modules.Validate<typeof(component), Class>
