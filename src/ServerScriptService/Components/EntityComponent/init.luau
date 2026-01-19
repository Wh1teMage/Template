local Interface = require('@ServerInterfaces/IEntityComponent')
local Modules = require('@ServerInterfaces/Modules')

local inject = {
  
}

local component = {} :: Modules.Class<Interface.Main, typeof(inject)>
component.Inject = inject

return component