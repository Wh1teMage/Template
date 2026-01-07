local ReplicatedStorage = game:GetService("ReplicatedStorage")

local charm = require(ReplicatedStorage.Packages.charm)

local testAtom = charm.atom({
    ['num'] = 123,
})

--[[
            PlayerAtom: struct {
                State: unknown,
                Data: unknown
            }
]]

local bar = {
    PlayerAtom = testAtom,
}

return bar :: typeof(bar) & {[number | string]: charm.Atom<any>,}