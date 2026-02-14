local ProfileValidation = require("@ReplicatedStorage/Interfaces/Validations/ProfileValidation")

export type Main<T = Main> = {
	values: {
		[string]: ProfileValidation.IProfile,
	},

	AddProfile: (self: T, profile: ProfileValidation.IProfile, name: string) -> (),
	RemoveProfile: (self: T, name: string) -> ProfileValidation.IProfile?,
	GetProfile: (self: T, name: string) -> ProfileValidation.IProfile?,
	GetProfiles: (self: T) -> { [string]: ProfileValidation.IProfile },
}

return {}
