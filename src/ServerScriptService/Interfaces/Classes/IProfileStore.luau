local ProfileValidation = require("@ReplicatedStorage/Interfaces/Validations/ProfileValidation")

export type Main = {
    values: {
        [string]: ProfileValidation.IProfile,
    },

    AddProfile: (self: Main, profile: ProfileValidation.IProfile, name: string) -> (),
    RemoveProfile: (self: Main, name: string) -> ProfileValidation.IProfile?,
    GetProfile: (self: Main, name: string) -> ProfileValidation.IProfile?,
    GetProfiles: (self: Main) -> {[string]: ProfileValidation.IProfile},
}

return {}