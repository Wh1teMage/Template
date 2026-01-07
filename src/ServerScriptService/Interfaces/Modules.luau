local ServerScriptService = game:GetService("ServerScriptService")

local ITestComponent = require(ServerScriptService.Container.Interfaces.ITestComponent)
local ITestComponentcopy = require(ServerScriptService.Container.Interfaces["ITestComponent copy"])

export type Types = {
    TestComponent: ITestComponent.Main,
    ITestComponentcopy: ITestComponentcopy.Main
}

return {} :: {
    TestComponent: 'TestComponent',
    ITestComponentcopy: 'ITestComponentcopy'
}