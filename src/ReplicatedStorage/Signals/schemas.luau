local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm_sync = require(ReplicatedStorage.Packages["charm-sync"])

--@schema-remote
export type Sync = charm_sync.SyncPayload

--@schema-remote
export type Hydrate = nil

--@schema-bindable-server
export type Test = {
    ['message']: string
}

--@schema-remote
export type Test2 = {
    ['message']: string
}

return {}