local ProfileValidation = require("../Validations/ProfileValidation")
local SessionValidation = require("../Validations/SessionValidation")

export type IPlayerData = {
	Profile: ProfileValidation.IProfile,
	Session: SessionValidation.ISession,
}

return {}
