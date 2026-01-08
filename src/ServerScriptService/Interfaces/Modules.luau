-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Utilities.Container.types)
local ICharm = require(script.Parent.ICharm)
local ICharmSync = require(script.Parent.ICharmSync)
local IEntityComponent = require(script.Parent.IEntityComponent)
local IPlayerComponent = require(script.Parent.IPlayerComponent)
local ISpring = require(script.Parent.ISpring)
local ITestComponent = require(script.Parent.ITestComponent)
local ITestComponentCopy = require(script.Parent.ITestComponentCopy)

export type Class<class=any, inject=any> =
    class & types.InjectedClass<inject, types.filterModuleTypes<Types, inject>>

export type Types = {
    Charm: ICharm.Main,
    CharmSync: ICharmSync.Main,
    EntityComponent: IEntityComponent.Main,
    PlayerComponent: IPlayerComponent.Main,
    Spring: ISpring.Main,
    TestComponent: ITestComponent.Main,
    TestComponentCopy: ITestComponentCopy.Main,
}

return {
    Charm = 'Charm',
    CharmSync = 'CharmSync',
    EntityComponent = 'EntityComponent',
    PlayerComponent = 'PlayerComponent',
    Spring = 'Spring',
    TestComponent = 'TestComponent',
    TestComponentCopy = 'TestComponentCopy',
} :: {
    Charm : 'Charm',
    CharmSync : 'CharmSync',
    EntityComponent : 'EntityComponent',
    PlayerComponent : 'PlayerComponent',
    Spring : 'Spring',
    TestComponent : 'TestComponent',
    TestComponentCopy : 'TestComponentCopy',
}
