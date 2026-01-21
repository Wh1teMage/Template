local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signals = require(ReplicatedStorage.Signals)

Signals.Test3:Fire({data = '123'})

local client = require("@Utilities/Replica/client")

--Signals.Test2:Fire({message = 'hi'})
--Signals.Test2:Fire({message = 'hi2'})
