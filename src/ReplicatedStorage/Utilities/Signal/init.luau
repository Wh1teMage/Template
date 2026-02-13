local RunService = game:GetService("RunService")

local Enums = require("@Info/Enums")
local gt = require("@Packages/greentea")
local Serializer = require("@self/Serializer")

local signal = {}
signal.__index = signal

local signals = {
	[Enums.EventType.Bindable] = {},
	[Enums.EventType.Remote] = {},
}

local registeredRemotes = {}

local function triggerRemote(name: string, ...)
	local event = signals[Enums.EventType.Remote][name] :: any
	if not event then
		warn(`{name} remote isnt registered but the instance already triggered!`)
		return
	end

	event.Validator:assert(RunService:IsClient() and ... or table.unpack({ ... }, 2))

	for _, connection in pairs(event.Connections) do
		connection(...)
	end
end

local function connectRemote(remote: RemoteEvent)
	if registeredRemotes[remote] then return end

	if RunService:IsClient() then
		remote.OnClientEvent:Connect(function(name: string, ...)
			triggerRemote(name, Serializer:Deserialize(...))
		end)
	else
		remote.OnServerEvent:Connect(function(player: Player, name: string, ...)
			triggerRemote(name, player, Serializer:Deserialize(...))
		end)
	end

	warn(`--- {RunService:IsClient() and "Client" or "Server"} {remote} remote registered successfully! ---`)
	registeredRemotes[remote] = true
end

script.ChildAdded:Connect(function(a0: Instance)
	if not a0:IsA("RemoteEvent") then return end
	connectRemote(a0)
end)

for _, a0 in pairs(script:GetChildren()) do
	if not a0:IsA("RemoteEvent") then continue end
	connectRemote(a0)
end

local GlobalEvent = script:FindFirstChild("Event") :: RemoteEvent?

if not GlobalEvent and RunService:IsServer() then
	GlobalEvent = Instance.new("RemoteEvent")
	GlobalEvent.Name = "Event"
	GlobalEvent.Parent = script
end

local fireTable = {
	[Enums.EventType.Bindable] = function(self: any, ...)
		for _, connection in pairs(self.Connections) do
			connection(...)
		end
	end,

	[Enums.EventType.Remote] = function(self: any, ...)
		assert(self.Instance, "GlobalEvent doesnt exist!")

		if RunService:IsClient() then
			self.Instance:FireServer(self.Name, Serializer:Serialize(...))
		else
			local args = { ... }
			if typeof(args[1]) ~= "Instance" then
				warn(`Player wasnt specified!`)
				return
			end

			local player = args[1] :: Player
			table.remove(args, 1)

			self.Instance:FireClient(player, self.Name, Serializer:Serialize(table.unpack(args)))
		end
	end,
}

function signal:CreateBindable(name: string, validator: gt.Type?)
	if signals[Enums.EventType.Bindable][name] then return signals[Enums.EventType.Bindable][name] end
	local event = setmetatable({
		Name = name,
		Connections = {},
		Type = Enums.EventType.Bindable,
		Validator = validator,
	}, signal)

	signals[event.Type][name] = event

	return event
end

function signal:CreateRemote(name: string, validator: gt.Type?)
	if signals[Enums.EventType.Remote][name] then return signals[Enums.EventType.Remote][name] end
	local event = setmetatable({
		Name = name,
		Connections = {},
		Type = Enums.EventType.Remote,
		Validator = validator,
	}, signal)

	local instance = script:FindFirstChild(name)

	signals[event.Type][name] = event

	if instance then
		event.Instance = instance
		return event
	end

	if RunService:IsServer() then
		instance = Instance.new("RemoteEvent")
		instance.Name = name
		instance.Parent = script
	else
		local connecton: RBXScriptConnection?

		task.delay(10, function()
			if not connecton then return end
			connecton:Disconnect()
		end)

		connecton = script.ChildAdded:Connect(function(a0: Instance)
			if not connecton then return end
			if a0.Name ~= name then return end

			instance = a0

			connecton:Disconnect()
			connecton = nil
		end)
	end

	if not instance then
		warn(`{name}'s instance is missing, switching to the default one`)
		instance = GlobalEvent
	end

	event.Instance = instance :: RemoteEvent

	return event
end

function signal.Connect(self: any, callback: (...any) -> any)
	table.insert(self.Connections, callback)
end

function signal.Fire(self: any, ...)
	self.Validator:assert(...)
	fireTable[self.Type](self, ...)
end

return signal
