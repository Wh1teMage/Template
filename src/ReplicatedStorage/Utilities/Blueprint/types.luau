local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Info.Enums)

export type class = {['__index']: any, ['new']: (...any) -> any}

export type function callConvert(constructor: type): type
    if (constructor:is('intersection')) then
        constructor = constructor:components()[1]
    end

    if (not constructor:is('function')) then error(`isnt a function, tag type is {constructor.tag}`) end

    local params= constructor:parameters()
    local head = params.head or {}

    local newFunction = types.newfunction()
    table.insert(head, 1, types.any)

    newFunction:setparameters(head, params.tail)
    newFunction:setreturns(constructor:returns().head)

    return newFunction
end

export type function concatTables(t1: type, t2: type): type 
    if (not t1:is('table')) then error() end

    local t3 = types.newtable()

    for name, type in pairs(t2:properties()) do
        t3:setproperty(name, type.read)
    end

    for name, type in pairs(t1:properties()) do
        t3:setproperty(name, type.read)
    end

    return t3
end

export type function construct(t1: type, t2: type, f1: type?): type 
    if (not t1:is('table')) then error() end

    local t3 = types.newtable()

    for name, type in pairs(t1:properties()) do
        t3:setproperty(name, type.read)
    end

    for name, type in pairs(t2:properties()) do
        t3:setproperty(name, type.read)
    end

    if (not f1 or f1:is('any')) then 
        return t3 
    end
    --if (not f1:is('function')) then error() end

    f1:setreturns({t3})
    t3:setproperty(types.singleton('new'), f1)

    return t3
end



export type NodeMethods = {
    _onStart: (self: any) -> (), 
    _onComplete: (self: any) -> (),
    _onCancel: (self: any) -> (),
    start: (self: any) -> (),
    complete: (self: any) -> (),
    cancel: (self: any) -> (),
}

export type NodeFields = {
    status: string,
    context: {[any]: any},
}

export type Node = concatTables<NodeMethods, NodeFields>

return {}