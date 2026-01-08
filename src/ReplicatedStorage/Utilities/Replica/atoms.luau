local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm = require(ReplicatedStorage.Packages.charm)

local data = {
    ['num'] = 123,
}

local testAtom: charm.Atom<typeof(data)> = charm.atom(data)

local bar = {
    PlayerAtom = testAtom,
}

return bar :: typeof(bar) & {[number | string]: charm.Atom<any>,}