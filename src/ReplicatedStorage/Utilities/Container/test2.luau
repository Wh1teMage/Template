--!strict

type ModuleTypes = {
    Test: { Test: () -> () },
    Hello: { Hi: () -> () },
    Database: { Query: (string) -> {string} },
}

type ModuleKeys = keyof<ModuleTypes>  -- "Test" | "Hello" | "Database"

type function filterModuleTypes(allModules: type, keys: type): type
    if not allModules:is("table") then
        error("allModules must be a table")
    end
    
    local result = types.newtable()
    
    if keys:is("union") then
        for _, property in keys:components() do
            if property:is("singleton") then
                local propType = allModules:readproperty(property)
                if propType then
                    result:setproperty(property, propType)
                end
            end
        end
    elseif keys:is("singleton") then
        local propType = allModules:readproperty(keys)
        if propType then
            result:setproperty(keys, propType)
        end
    end
    
    return result
end

-- ✅ Intersection вместо extends!
type Module<I> = I & ModuleKeys & {
    Name: string,
    Inject: I,
    Dependencies: filterModuleTypes<ModuleTypes, I>,
}

-- Studio ПОДПОЛНИТ при написании!
type MyModule = Module<"Test" | "Database">
-- 👆 Пиши "T" → автоподсказка "Test"! "D" → "Database"!
