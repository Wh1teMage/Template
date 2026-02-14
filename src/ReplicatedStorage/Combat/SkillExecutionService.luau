local charm = require("@Packages/charm")
local charm_sync = require("@Packages/charm-sync")
local janitor = require("@Packages/janitor")

local UtilityComponent = require("@Utilities/Components/UtilityComponent")
local Actor = require("./Actor")
local Skill = require("./Skill")

local service = {}
service.__index = service

type StatesMap = { [string]: { state: string } }

type Fields = {
	_skills: { [string]: Skill.Instance },

	_janitor: janitor.Janitor,

	_setSkillStates: (states: StatesMap) -> (),
	_getSkillStates: () -> StatesMap,

	_replicateServerFunction: (player: Player, signals: any) -> (),
}

-- ^ change from any

type Class = setmetatable<Fields, { __index: typeof(service) }>

function service.constructor()
	local self = setmetatable({
		_skills = {},
	}, service) :: Class

	self._getSkillStates, self._setSkillStates = charm.signal({})
	self._janitor = janitor.new()

	charm_sync.server.connect(self._replicateServerFunction)

	return self
end

function service.AddPlayerReplication(self: Class, player: Player)
	charm_sync.server.addSignalsToClient(player, {
		skillStates = self._getSkillStates(),
	})
end

function service.AddClientReplication(self: Class)
	charm_sync.client.addSignals({
		skillStates = self._setSkillStates,
	})
end

function service.Patch<T>(self: Class, payloads: T)
	charm_sync.client.patch(payloads)
end

function service.PrepareReplicationData(self: Class)
	local data = {}

	for id, instance in self._skills do
		data[id] = { state = instance:GetState() :: string }
	end

	self._setSkillStates(data)
	-- ^ check how this thing works
end

function service.CreateSkill(self: Class, skill: Skill.Class, actor: Actor.Instance)
	local id = tostring(UtilityComponent:GenerateId())

	local skillInstance = skill.new()
	skillInstance:SetActorId(id)

	self._janitor:Add(skillInstance.stateChanged:Connect(function()
		self:PrepareReplicationData()
	end))

	self._skills[id] = skillInstance
	return skillInstance
end

function service.GetSkillById(self: Class, id: string)
	return self._skills[id]
end

function service.StartSkill(self: Class, skill: Skill.Instance, actor: Actor.Instance)
	assert(actor:GetSkillId(skill.id), `{actor.id} doesnt have a {skill.name} skill!`)
	skill:Start()
end

function service.InterruptSkill(self: Class, skill: Skill.Instance, actor: Actor.Instance)
	assert(actor:GetSkillId(skill.id), `{actor.id} doesnt have a {skill.name} skill!`)
	skill:Interrupt()
end

return service :: Class
