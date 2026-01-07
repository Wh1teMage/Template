local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Enums = require(ReplicatedStorage.Info.Enums)

local types = require(script.types)
type event = types.Event

local signal = {}

local signals = {
    ['Events'] = {} :: {[string]: event},
    ['Bindable'] = {} :: {[string]: event}
}

local GlobalEvent = script:FindFirstChildWhichIsA('RemoteEvent')

if (not GlobalEvent) and RunService:IsServer() then
    GlobalEvent = Instance.new('RemoteEvent')
    GlobalEvent.Name = 'Event'
    GlobalEvent.Parent = script
end

local methods = {}
methods.__index = methods

local function triggerEvent(name: string, scope: string, ...)
    local event = signals['Events'][name]
    if (not event) then
        warn(`{event} scope doesnt exist!`)
        return
    end

    local scopeConnections = event.Connections[scope]
    if (not scopeConnections) then
        warn(`{scope} scope doesnt exist!`)
        return
    end

    for _, connection in pairs(scopeConnections) do
        connection(...)
    end
end

if RunService:IsClient() then
    assert(GlobalEvent, 'GlobalEvent doesnt exist!')

    GlobalEvent.OnClientEvent:Connect(function(name: string, scope: string, ...)
        triggerEvent(name, scope, ...)
    end)
else
    assert(GlobalEvent, 'GlobalEvent doesnt exist!')

    GlobalEvent.OnServerEvent:Connect(function(player: Player, name: string, scope: string, ...)
        triggerEvent(name, scope, player, ...)
    end)
end

local function createEvent(name: string)
    local self = setmetatable(
    {
        Name = name,
        Instance = nil :: RemoteEvent?,
        Connections = {},
        WaitConnections = {},
        OnceConnections = {},
        Type = Enums.EventType.Remote
    }, methods) :: event

    return self
end

local fireTable = {
    [Enums.EventType.Bindable] = function(self: event, scope: string, ...)
        local scopeConnections = self.Connections[scope]
        if (not scopeConnections) then
            warn(`{scope} scope doesnt exist!`)
            return
        end

        for _, connection in pairs(scopeConnections) do
            connection(...)
        end
    end,

    [Enums.EventType.Remote] = function(self: event, scope: string, ...)
        assert(self.Instance, 'GlobalEvent doesnt exist!')

        if (RunService:IsClient()) then
            self.Instance:FireServer(self.Name, scope, ...)
        else
            local args = {...}
            if (typeof(args[1]) ~= 'Instance') then 
                warn(`Player wasnt specified!`)
                return
            end

            local player = args[1] :: Player
            table.remove(args, 1)

            self.Instance:FireClient(player, self.Name, scope, table.unpack(args))
        end
    end
}

function signal:GetEvent(name: string)
    if (signals["Events"][name]) then return signals["Events"][name] end

    local event = createEvent(name)
    signals["Events"][name] = event

    if (not GlobalEvent) then GlobalEvent = script:FindFirstChildWhichIsA('RemoteEvent') end
    assert(GlobalEvent, 'GlobalEvent doesnt exist!')

    event.Type = Enums.EventType.Remote
    event.Instance = GlobalEvent

    return event
end

function signal:GetBindable(name: string)
    if (signals["Bindable"][name]) then return signals["Bindable"][name] end

    local event = createEvent(name)
    signals["Bindable"][name] = event

    event.Type = Enums.EventType.Bindable

    return event
end

function methods.Fire(self: event, scope: string, ...)
    fireTable[self.Type](self, scope, ...)
end

function methods.FireAll(self: event, scope: string, ...)
    if (self.Type == Enums.EventType.Bindable) then
        warn('Bindable doesnt have a FireAll Method!')
        return
    end

    if (RunService:IsClient()) then
        warn('Client doesnt have a FireAll Method!')
        return
    end

    assert(self.Instance, 'GlobalEvent doesnt exist!')

    for _, player in pairs(Players:GetPlayers()) do
        self.Instance:FireClient(player, scope, ...)
    end
end

function methods.FireInRadius() -- tb impl
    
end

function methods.Connect(self: event, scope: string, callback: (...any) -> any)
    if (not self.Connections[scope]) then
        self.Connections[scope] = {}
    end

    table.insert(self.Connections[scope], callback)
end

return signal