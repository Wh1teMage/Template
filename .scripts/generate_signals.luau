-- gen.lua
-- run with: lune gen.lua

local fs = require("@lune/fs")
local path = require("@lune/path")

--------------------------------------------------
-- Paths
--------------------------------------------------


local SCHEMAS_FILE = '/src/ReplicatedStorage/Signals/schemas.luau'
local OUT_CLIENT = '/src/ReplicatedStorage/Signals/init.luau'
local OUT_SERVER = '/src/ServerScriptService/Signals/init.luau'

--------------------------------------------------
-- Read schemas.lua
--------------------------------------------------

local source = fs.readFile(SCHEMAS_FILE)

---@class Schema
---@field name string
---@field kind string

---@type Schema[]
local schemas = {}

--------------------------------------------------
-- Parsing (Lua patterns, NOT regex)
--------------------------------------------------
-- Lua patterns:
--  - %-  => literal "-"
--  - %s  => whitespace
--  - %w  => [A-Za-z0-9_]
--  - .-  => non-greedy

for annotation, name in source:gmatch(
    "%-%-@schema%-(%S+)%s*export%s+type%s+(%w+)"
) do
    table.insert(schemas, {
        name = name,
        kind = annotation,
    })
end

--------------------------------------------------
-- Client generators (dispatch table)
--------------------------------------------------

local clientGenerators = {
    remote = function(schema)
        return string.format(
            "    %s = Signal:CreateRemote('%s') :: types.ClientScope<schemas.%s>,",
            schema.name,
            schema.name,
            schema.name
        )
    end,

    ["bindable-client"] = function(schema)
        return string.format(
            "    %s = Signal:CreateBindable('%s') :: types.BindableScope<schemas.%s>,",
            schema.name,
            schema.name,
            schema.name
        )
    end,
}

--------------------------------------------------
-- Server generators (dispatch table)
--------------------------------------------------

local serverGenerators = {
    remote = function(schema)
        return string.format(
            "    %s = Signal:CreateRemote('%s') :: types.ServerScope<schemas.%s>,",
            schema.name,
            schema.name,
            schema.name
        )
    end,

    ["bindable-server"] = function(schema)
        return string.format(
            "    %s = Signal:CreateBindable('%s') :: types.BindableScope<schemas.%s>,",
            schema.name,
            schema.name,
            schema.name
        )
    end,
}

--------------------------------------------------
-- File templates
--------------------------------------------------

local CLIENT_HEADER = {
    "-- AUTO-GENERATED. DO NOT EDIT.",
    "",
    "local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
    "",
    "local Signal = require(ReplicatedStorage.Utilities.Signal)",
    "local types = require(ReplicatedStorage.Utilities.Signal.types)",
    "local schemas = require(script.schemas)",
    "",
    "return {",
}

local SERVER_HEADER = {
    "-- AUTO-GENERATED. DO NOT EDIT.",
    "",
    "local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
    "",
    "local schemas = require(ReplicatedStorage.Signals.schemas)",
    "local Signal = require(ReplicatedStorage.Utilities.Signal)",
    "local types = require(ReplicatedStorage.Utilities.Signal.types)",
    "",
    "return {",
}

--------------------------------------------------
-- Generation helpers
--------------------------------------------------

local function generateFile(header, generators)
    local lines = table.clone(header)

    for _, schema in ipairs(schemas) do
        local gen = generators[schema.kind]
        if gen then
            table.insert(lines, gen(schema))
        end
    end

    table.insert(lines, "}")
    return table.concat(lines, "\n")
end

--------------------------------------------------
-- Write output
--------------------------------------------------

fs.writeFile(OUT_CLIENT, generateFile(CLIENT_HEADER, clientGenerators))
fs.writeFile(OUT_SERVER, generateFile(SERVER_HEADER, serverGenerators))

print("Signals generated successfully")
