local wrapper = {}
local types = require(script.Parent.types)

type class = types.class

function wrapper.new(origin: class, parent: class?)
    local self = setmetatable(origin, {
        __index = parent,
        __call = function(class, ...) 
            if (not class['new']) then return end 
            return class['new'](...)
        end
    })
    self.__index = self

    return self
end

return setmetatable(wrapper, {
    __call = function<T>(_, origin: T, parent: any?)
        return (wrapper.new(origin, parent) :: any) :: index<T, 'new'>
        -- setmetatable<T, { __call: types.callConvert<index<T, 'new'>> }>
        --types.callConvert<index<T, 'new'>>
        --setmetatable<T & class, { __call: types.callConvert<index<T, 'new'>> }>
        --setmetatable<{}, { __call: (_:any, param: string) -> any }>   --index<T, 'new'>
        --typeof(setmetatable({}, {} :: { __call: () -> any}))
    end
})

--return (Wrapper(node, controlNode) :: any) :: setmetatable<{}, { __call: (_: any, params: any) -> Node}>

--[[
return setmetatable(wrapper, {
    __call = function(_,parent)
        local wrapped = setmetatable({}, {
            __index = parent,
            __call = function(class, ...) 
                if (not class['new']) then return end 
                return class['new'](...)
            end
        })

        wrapped.__index = wrapped

        return wrapped
    end
})
    ]]