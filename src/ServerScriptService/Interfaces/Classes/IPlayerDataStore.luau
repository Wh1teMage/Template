local PlayerData = require("@ReplicatedStorage/Interfaces/Types/PlayerData")

export type Main = {
    values: {
        [string]: PlayerData.IPlayerData
    },

    AddPlayer: (self: Main, playerData: PlayerData.IPlayerData, name: string) -> (),
    RemovePlayer: (self: Main, name: string) -> PlayerData.IPlayerData?,
    GetPlayer: (self: Main, name: string) -> PlayerData.IPlayerData?,
    GetPlayers: (self: Main) -> {[string]: PlayerData.IPlayerData},
}

return {}