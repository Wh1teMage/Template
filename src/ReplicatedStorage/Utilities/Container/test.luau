
local keys = {} :: {
    Test: 'Test',
    Hello: 'Hello',
    Database: 'Database',
}

type ModuleTypes = {
    Test: { Test: () -> () },
    Hello: { Hi: () -> () },
    Database: { Query: (string) -> {string} },
}

type function filterModuleTypes(array: type)
    local result = types.newtable()

    if (not ModuleTypes:is("table")) then return result end
    if (not array:is("table")) then return result end

    local readIndexer = array:readindexer()
    if (not readIndexer) then return result end

    local filter = readIndexer.result

    if filter:is('singleton') then
        local propType = ModuleTypes:readproperty(filter)
        if (not propType) then return result end
        result:setproperty(filter, propType)
        return result
    end

    for _, property in filter:components() do 
        local propType = ModuleTypes:readproperty(property)
        if (not propType) then continue end
        result:setproperty(property, propType)
    end
    
    return result
end

local Inject = {keys.Test}

type ModuleTypes2 = filterModuleTypes<typeof(Inject)> 