local PlayerData = require("@ReplicatedStorage/Interfaces/Types/PlayerData")

export type Main<T=Main> = {
    values: {
        [string]: PlayerData.IPlayerData
    },

    AddPlayer: (self: T, playerData: PlayerData.IPlayerData, name: string) -> (),
    RemovePlayer: (self: T, name: string) -> PlayerData.IPlayerData?,
    GetPlayer: (self: T, name: string) -> PlayerData.IPlayerData?,
    GetPlayers: (self: T) -> {[string]: PlayerData.IPlayerData},
}

return {}