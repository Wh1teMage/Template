local Interface = require('@ServerInterfaces/Classes/IEntityComponent')
local Modules = require('@ServerInterfaces/Classes/Modules')

local inject = {
  
}

local component = {} :: Modules.Class<Interface.Main, typeof(inject)>

return component