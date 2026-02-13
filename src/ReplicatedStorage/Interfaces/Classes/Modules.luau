-- AUTO-GENERATED. DO NOT EDIT.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local types = require(ReplicatedStorage.Utilities.Container.types)

local mapping = {} :: {}

export type Class<class = { Name: string, Inject: {} }, fields = {}> =
	class
	& fields
	& types.SatisfiedClass<types.filterModuleTypes<Types, index<class, "Inject">>>

export type Validate<class = { Name: string, Inject: {} }, generated = {}> = types.validateClass<
	class,
	index<Types<generated>, index<class, "Name">>
>

export type Types<T = any> = {}

return mapping
