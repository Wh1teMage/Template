-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Utilities.Container.types)
local ICharm = require(script.Parent.ICharm)
local ICharmSync = require(script.Parent.ICharmSync)
local ISpring = require(script.Parent.ISpring)

export type Class<class=any, inject=any> =
    class & types.InjectedClass<inject, types.filterModuleTypes<Types, inject>>

export type Types = {
    Charm: ICharm.Main,
    CharmSync: ICharmSync.Main,
    Spring: ISpring.Main,
}

return {
    Charm = 'Charm',
    CharmSync = 'CharmSync',
    Spring = 'Spring',
} :: {
    Charm : 'Charm',
    CharmSync : 'CharmSync',
    Spring : 'Spring',
}
