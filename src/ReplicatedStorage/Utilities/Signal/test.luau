--[[local signal = {}

function signal.new()
    local self = {}

    return self
end

local scope = {}
scope.__index = scope

function scope.new<T>(payload: T)
    local self = setmetatable({
        payload = nil :: T
    }, scope)

    return self
end

local schema = {
    ['test'] = 'hi'
}

--@schema
type test = typeof(schema)

local test = scope.new({} :: test)

local scopes = {
    ['test'] = test
}]]

local scope = {}
scope.__index = scope

-- Определяем тип Scope через generic --! вот это полностью правильное решение для схем
export type Scope<T> = {
    Fire: (self: Scope<T>, payload: T) -> (),
    Connect: (self: Scope<T>, callback: (T) -> ()) -> ()
}

-- Создаём новый scope с типом T
function scope.new<T>(): Scope<T>
    local self = setmetatable({
        Connections = {} :: {((T) -> ())},
    }, scope)

    return self :: any
end

-- Fire: принимает payload типа T
function scope:Fire(payload)
    -- IDE теперь понимает payload как T
    for _, callback in pairs(self.Connections) do
        callback(payload)
    end
end

-- Connect: callback получает payload типа T
function scope:Connect(callback)
    table.insert(self.Connections, callback)
end

-- Схема payload
local schema = {
    message = "hello",
    count = 1
}

-- @schema
type TestPayload = typeof(schema)

-- Создаём scope с payload типа TestPayload
local test = scope.new() :: Scope<TestPayload>

-- Fire: IDE проверяет тип
test:Fire({
    message = "hi",
    count = 10
})

-- IDE выдаст ошибку, если payload не соответствует TestPayload
-- test:Fire({ message = 123 }) -- Ошибка

-- Connect: callback получает payload типа TestPayload
test:Connect(function(payload)
    print(payload.message) -- string
    print(payload.count)   -- number
end)