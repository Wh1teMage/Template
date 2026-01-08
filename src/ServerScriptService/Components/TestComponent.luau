local component = setmetatable({}, {__call = function() print('123') end})

function component.sayHello()
    print("Hello from TestComponent!")
end

return component