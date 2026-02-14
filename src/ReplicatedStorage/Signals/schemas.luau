local gt = require("@Packages/greentea")

local schemas = {}

--@schema-remote
schemas["Test3"] = gt.table({
	data = gt.string(),
})

--@schema-remote
schemas["Sync"] = gt.any()

--@schema-remote
schemas["Hydrate"] = gt.any({ allowNil = true })

return schemas

--[[
Subscribe1(obj (status))
Subscribe2(obj (status))

Fire -> EventBus -> for (subscribers) -> Subscribe1 -> obj.status -> cancelled -> break
]]
