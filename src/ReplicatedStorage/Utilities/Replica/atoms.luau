local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm = require(ReplicatedStorage.Packages.charm)

local testAtom = charm.atom({['test'] = 123})

local bar = {
    hi = testAtom,
    hi2 = testAtom,
}

return bar :: typeof(bar) & {[number | string]: charm.Atom<any>,}