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
    Inject: T,
    Dependencies: F,
    Scope: string?,
    constructor: (() -> any),
}

export type Container = {
    Elements: { [string]: InjectedClass<any> }, -- {string}?
    new: () -> Container,
    Inject: (self: Container, class: InjectedClass<any>) -> (),
    Register: (self: Container, name: string, class: InjectedClass<any>) -> (),
}

return {}