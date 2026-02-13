local PlayerData = require("@ClientInterfaces/Types/PlayerData")
local charm = require("@Packages/charm")

local PlayerAtoms: charm.Atom<{ [string]: PlayerData.IPlayerData }> = charm.atom({})
local TestAtom: charm.Atom<{ foo: string, bar: { test: number } }> = charm.atom({
	foo = "hello",
	bar = { test = 123 },
})

return {
	PlayerAtoms = PlayerAtoms,
	Test = TestAtom,
}
