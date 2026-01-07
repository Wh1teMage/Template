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

export type NodeMethods = {
    _onStart: (self: Node) -> (),
    _onComplete: (self: Node) -> (),
    _onCancel: (self: Node) -> (),
    start: (self: Node) -> (),
    complete: (self: Node) -> (),
    cancel: (self: Node) -> (),
}

export type NodeFields = {
    status: string,
    context: {[any]: any},
}

export type Node = NodeFields & NodeMethods

return {}