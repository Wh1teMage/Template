local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charmSync = require(ReplicatedStorage.Packages["charm-sync"])
export type Main = typeof(charmSync)

return {}