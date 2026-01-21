local Interface = require('@ServerInterfaces/Classes/IProfileStore')
local Modules = require('@ServerInterfaces/Classes/Modules')

local inject = {
  
}

local component = {} :: Modules.Class<Interface.Main, typeof(inject)>
component.Inject = inject



return component