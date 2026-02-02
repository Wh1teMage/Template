-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Utilities.Container.types)
local IEntityComponent = require(script.Parent.IEntityComponent)
local IPlayerComponent = require(script.Parent.IPlayerComponent)
local IPlayerDataStore = require(script.Parent.IPlayerDataStore)
local IProfileStore = require(script.Parent.IProfileStore)
local ITestComponent = require(script.Parent.ITestComponent)
local ITestComponentCopy = require(script.Parent.ITestComponentCopy)

local mapping = {
	EntityComponent = "EntityComponent",
	PlayerComponent = "PlayerComponent",
	PlayerDataStore = "PlayerDataStore",
	ProfileStore = "ProfileStore",
	TestComponent = "TestComponent",
	TestComponentCopy = "TestComponentCopy",
} :: {
	EntityComponent: "EntityComponent",
	PlayerComponent: "PlayerComponent",
	PlayerDataStore: "PlayerDataStore",
	ProfileStore: "ProfileStore",
	TestComponent: "TestComponent",
	TestComponentCopy: "TestComponentCopy",
}

export type Class<class = { Name: string, Inject: {} }, fields = {}> =
	class
	& fields
	& types.SatisfiedClass<types.filterModuleTypes<Types, index<class, "Inject">>>

export type Validate<class = { Name: string, Inject: {} }, generated = {}> = types.validateClass<
	class,
	index<Types<generated>, index<class, "Name">>
>

export type Types<T = any> = {
	EntityComponent: IEntityComponent.Main<T>,
	PlayerComponent: IPlayerComponent.Main<T>,
	PlayerDataStore: IPlayerDataStore.Main<T>,
	ProfileStore: IProfileStore.Main<T>,
	TestComponent: ITestComponent.Main<T>,
	TestComponentCopy: ITestComponentCopy.Main<T>,
}

return mapping
