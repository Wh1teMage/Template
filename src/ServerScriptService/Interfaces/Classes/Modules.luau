-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Utilities.Container.types)
local IEntityComponent = require(script.Parent.IEntityComponent)
local IPlayerComponent = require(script.Parent.IPlayerComponent)
local IPlayerDataStore = require(script.Parent.IPlayerDataStore)
local IProfileStore = require(script.Parent.IProfileStore)
local ITestComponent = require(script.Parent.ITestComponent)
local ITestComponentCopy = require(script.Parent.ITestComponentCopy)

export type Class<class=any, inject=any> =
    class & types.InjectedClass<inject, types.filterModuleTypes<Types, inject>>

export type Types = {
    EntityComponent: IEntityComponent.Main,
    PlayerComponent: IPlayerComponent.Main,
    PlayerDataStore: IPlayerDataStore.Main,
    ProfileStore: IProfileStore.Main,
    TestComponent: ITestComponent.Main,
    TestComponentCopy: ITestComponentCopy.Main,
}

return {
    EntityComponent = 'EntityComponent',
    PlayerComponent = 'PlayerComponent',
    PlayerDataStore = 'PlayerDataStore',
    ProfileStore = 'ProfileStore',
    TestComponent = 'TestComponent',
    TestComponentCopy = 'TestComponentCopy',
} :: {
    EntityComponent : 'EntityComponent',
    PlayerComponent : 'PlayerComponent',
    PlayerDataStore : 'PlayerDataStore',
    ProfileStore : 'ProfileStore',
    TestComponent : 'TestComponent',
    TestComponentCopy : 'TestComponentCopy',
}
