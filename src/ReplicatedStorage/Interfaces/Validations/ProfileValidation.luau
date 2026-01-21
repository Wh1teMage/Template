local gt = require("@Packages/greentea")

local validation = gt.table{
    Values = gt.table({
        CoinsValue = gt.number(),
        WinsValue = gt.number(),
    }),

    Multipliers = gt.table({
        CoinsMultiplier = gt.number(),
        WinsMultiplier = gt.number(),
    }),

    Config = gt.table({
        FirstJoin = gt.number(),
        LastJoined = gt.number(),

        SpinCount = gt.number(),

        DayAmount = gt.number(),
        IngameTime = gt.number(),

        Donated = gt.number(),
        Luck = gt.number(),
    }),

    Products = gt.table({}),
    Items = gt.table({}),

    CarSettings = gt.table({}),
    Settings = gt.table({}),
    Codes = gt.table({}),

    Cars = gt.table({}),
    Maps = gt.array(gt.string()),

    Constants = gt.table({
        VERSION = gt.number(),
    }),
}

export type IProfile = typeof(validation)

return validation