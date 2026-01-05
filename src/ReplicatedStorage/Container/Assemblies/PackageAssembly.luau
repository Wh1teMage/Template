local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Packages = ReplicatedStorage:WaitForChild('Packages')

local charm = require(Packages:WaitForChild('charm'))
local charmSync = require(Packages:WaitForChild('charm-sync'))
local spring = require(Packages:WaitForChild('spring'))

return {
    Charm = charm,
    CharmSync = charmSync,
    Spring = spring,
} :: {
    [string]: any,
}