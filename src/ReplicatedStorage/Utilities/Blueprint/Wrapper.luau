local wrapper = {}
local types = require('./types')

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
    end
})