local ProfileValidation = require("@ReplicatedStorage/Types/Validations/ProfileValidation")

export type ProfileTemplate = ProfileValidation.IProfile

local template: ProfileTemplate = {
    Values = {
        CoinsValue = 0,
        WinsValue = 0,
    },

    Multipliers = {
        CoinsMultiplier = 1,
        WinsMultiplier = 1,
    },

    Config = {
        FirstJoin = os.time(),
        LastJoined = os.time(),

        SpinCount = 0,

        DayAmount = 0,
        IngameTime = 0,

        Donated = 0,
        Luck = 0,
    },

    Products = {},
    Items = {},

    CarSettings = {},
    Settings = {},
    Codes = {},

    Cars = {},
    Maps = {},

    Constants = {
        VERSION = 1,
    },
}

return template