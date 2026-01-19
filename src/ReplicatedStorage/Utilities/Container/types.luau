local Enums = require("@Info/Enums")

export type function filterModuleTypes(modules: type, array: type): type  
    local result = types.newtable()

    if (not modules:is("table")) then return result end
    if (not array:is("table")) then return result end

    local readIndexer = array:readindexer()
    if (not readIndexer) then return result end

    local filter = readIndexer.result

    if filter:is('singleton') then
        local propType = modules:readproperty(filter)
        if (not propType) then return result end
        result:setproperty(filter, propType)
        return result
    end

    for _, property in filter:components() do 
        local propType = modules:readproperty(property)
        if (not propType) then continue end
        result:setproperty(property, propType)
    end
    
    return result
end

export type InjectedClass<T=any, F=any> = {
    Name: string?,
    Injected: boolean,
    Initialized: boolean,
    Priority: number,
    Inject: T,
    Dependencies: F,
    Scope: keyof<typeof(Enums.Class)>,
    constructor: (() -> any)?,
    start: (() -> any)?,
}

export type Container = {
    registered: boolean,
    Elements: { [string]: InjectedClass<any> }, -- {string}?
    new: () -> Container,
    Inject: (self: Container, class: InjectedClass<any>) -> (),
    RegisterModule: (self: Container, name: string, class: InjectedClass<any>) -> (),
    RegisterDirectory: (self: Container, dir: Instance) -> (),
    Start: (self: Container) -> (),
}

--ITestComponentCopy.Main & types.InjectedClass<typeof(inject), types.filterModuleTypes<Modules.Types, typeof(inject)>>

return {}