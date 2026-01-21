local ITestComponentCopy = require('@ServerInterfaces/Classes/ITestComponentCopy')
local Modules = require('@ServerInterfaces/Classes/Modules')

local inject = {
    Modules.TestComponent
}

local component = {} :: Modules.Class<ITestComponentCopy.Main, typeof(inject)>
component.Inject = inject

function component:test()
    print(component)
    component.Dependencies.TestComponent.sayHello()

    return nil
end

return component