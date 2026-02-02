local RunService = game:GetService("RunService")

local Utilities = {}

local counter = 1

function Utilities:GetBasedOnRuntime<T, G>(serverCall: T, clientCall: G)
	return RunService:IsServer() and serverCall or clientCall
end

function Utilities:GenerateId()
	counter += 1
	return counter
end
-- ^ rewrite

return Utilities
