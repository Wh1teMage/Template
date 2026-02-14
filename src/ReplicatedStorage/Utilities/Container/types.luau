local Enums = require("@Info/Enums")

export type function filterModuleTypes(modules: type, array: type): type
	local result = types.newtable()

	if not modules:is("table") then return result end
	if not array:is("table") then return result end

	local readIndexer = array:readindexer()
	if not readIndexer then return result end

	local filter = readIndexer.result

	if filter:is("singleton") then
		local propType = modules:readproperty(filter)
		if not propType then return result end
		result:setproperty(filter, propType)
		return result
	end

	for _, property in filter:components() do
		local propType = modules:readproperty(property)
		if not propType then continue end
		result:setproperty(property, propType)
	end

	return result
end

export type function validateClass(class: type, interface: type)
	assert(class:is("table"))
	assert(interface:is("table"))

	for index, value in interface:properties() do
		if not value.read or not value.read:is("function") then continue end
		local propType = class:readproperty(index)
		if not propType or value.read ~= propType then error(`class doesnt satisfy the class interface!`) end
	end

	return types.newtable()
end

export type InjectedClass<F = any> = {
	Name: string?,
	Injected: boolean,
	Initialized: boolean,
	Priority: number,
	Inject: { string },
	Dependencies: F,
	Scope: keyof<typeof(Enums.Class)>,
	constructor: (() -> any)?,
	start: (() -> any)?,
}

export type SatisfiedClass<T = {}> = {
	Dependencies: T,
}

export type Container = {
	registered: boolean,
	Elements: { [string]: InjectedClass }, -- {string}?
	new: () -> Container,
	Inject: (self: Container, class: InjectedClass) -> (),
	RegisterModule: (self: Container, name: string, class: InjectedClass) -> (),
	RegisterDirectory: (self: Container, dir: Instance) -> (),
	Start: (self: Container) -> (),
}

--ITestComponentCopy.Main & types.InjectedClass<typeof(inject), types.filterModuleTypes<Modules.Types, typeof(inject)>>

return {}
