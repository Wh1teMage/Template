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
--[[
type ScopeBase = {
    Name: string,
    Type: keyof<typeof(Enums.EventType)>,
}

export type RequestScope<T> = {
    Fire: (self: RequestScope<T>, payload: T) -> (),
    FireAll: (self: RequestScope<T>, payload: T) -> (),
    FireInRadius: (self: RequestScope<T>) -> (), -- tb implemented
} & ScopeBase

export type RecieveScope<T> = {
    Connections: {(payload: T) -> any},
    Connect: (self: RecieveScope<T>, callback: (payload: T) -> any) -> (),
} & ScopeBase
]]

export type BindableScope<T> = {
    Name: string,
    Type: keyof<typeof(Enums.EventType)>,

    Fire: (self: ClientScope<T>, payload: T) -> (),
    Connections: {(payload: T) -> any},
    Connect: (self: BindableScope<T>, callback: (payload: T) -> any) -> (),
}

export type ClientScope<T> = {
    Name: string,
    Type: keyof<typeof(Enums.EventType)>,

    Fire: (self: ClientScope<T>, payload: T) -> (),
    Connections: {(payload: T) -> any},
    Connect: (self: ClientScope<T>, callback: (payload: T) -> any) -> (),
}

export type ServerScope<T> = {
    Name: string,
    Type: keyof<typeof(Enums.EventType)>,

    Fire: (self: ServerScope<T>, player: Player, payload: T) -> (),
    FireAll: (self: ServerScope<T>, payload: T) -> (),
    FireInRadius: (self: ServerScope<T>) -> (), -- tb implemented

    Connections: {(payload: T) -> any},
    Connect: (self: ServerScope<T>, callback: (player: Player, payload: T) -> any) -> (),
}

return {}