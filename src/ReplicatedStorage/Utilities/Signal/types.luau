local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Info.Enums)

export type Event = {
    -- fields
    Name: string,
    Instance: RemoteEvent?,
    Connections: {[string]: {(...any) -> any}},
    WaitConnections: {[string]: {(...any) -> any}},
    OnceConnections: {[string]: {(...any) -> any}},
    Type: keyof<typeof(Enums.EventType)>,

    -- methods
    Fire: (self: Event, scope: string, ...any) -> (),
    FireAll: (self: Event, scope: string, ...any) -> (),
    FireInRadius: (self: Event) -> (), -- placeholder, as in implementation
    Connect: (self: Event, scope: string, callback: (...any) -> any) -> (),
}

return {}