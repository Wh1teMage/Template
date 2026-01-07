opt server_output = "./src/ServerScriptService/Events.luau"
opt client_output = "./src/ReplicatedStorage/Events.luau"

type CharmSyncPayload = enum { "init", "patch" }

event SyncState = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        data: struct {
            num: u8,
        },
        type: CharmSyncPayload
    }
}

event RequestState = {
    from: Client,
    type: Reliable,
    call: SingleAsync
}