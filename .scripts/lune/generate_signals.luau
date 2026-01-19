-- gen.lua
-- run with: lune gen.lua

local fs = require("@lune/fs")
local task = require("@lune/task")
local config = require('./config')

--------------------------------------------------
-- Paths
--------------------------------------------------


local SCHEMAS_FILE = config.SCHEMAS_FILE
local OUT_CLIENT = config.OUT_SINGALS_CLIENT
local OUT_SERVER = config.OUT_SINGALS_SERVER

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
    "%-%-@schema%-(%S+)%s*schemas%[%s*['\"](%w+)['\"]%s*%]"
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
            "    %s = Signal:CreateRemote('%s', gt.typecast(schemas.%s)) :: types.ClientScope<typeof(schemas.%s)>,",
            schema.name,
            schema.name,
            schema.name,
            schema.name
        )
    end,

    ["bindable-client"] = function(schema)
        return string.format(
            "    %s = Signal:CreateBindable('%s', gt.typecast(schemas.%s)) :: types.BindableScope<typeof(schemas.%s)>,",
            schema.name,
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
            "    %s = Signal:CreateRemote('%s', gt.typecast(schemas.%s)) :: types.ServerScope<typeof(schemas.%s)>,",
            schema.name,
            schema.name,
            schema.name,
            schema.name
        )
    end,

    ["bindable-server"] = function(schema)
        return string.format(
            "    %s = Signal:CreateBindable('%s', gt.typecast(schemas.%s)) :: types.BindableScope<typeof(schemas.%s)>,",
            schema.name,
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
    "local gt = require('@Packages/greentea')",
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
    "local gt = require('@Packages/greentea')",
    "local schemas = require(ReplicatedStorage.Signals.schemas)",
    "local Signal = require(ReplicatedStorage.Utilities.Signal)",
    "local types = require(ReplicatedStorage.Utilities.Signal.types)",
    "",
    "return {",
}

--------------------------------------------------
-- Generation helpers
--------------------------------------------------

local function generateFile(header: {string}, generators)
    local lines = table.clone(header)

    for _, schema in ipairs(schemas) do
        local kind: string = (schema :: any).kind :: any

        local gen = generators[kind] :: ((any) -> string)?
        if gen then
            table.insert(lines, gen(schema))
        end
    end

    table.insert(lines, "}")
    return table.concat(lines, "\n")
end

--------------------------------------------------
-- Simple file hash function
--------------------------------------------------

local lastHash = nil

local function hashFile(filePath): number?
    local content = fs.readFile(filePath)
    if not content then return nil end

    local sum = 0
    for i = 1, #content do
        sum = (sum + content:byte(i)) % 0xFFFFFFFF
    end

    return sum
end

--------------------------------------------------
-- Main watcher loop
--------------------------------------------------

print("Watching " .. SCHEMAS_FILE .. " for changes...")

while task.wait(2) do
    local currentHash = hashFile(SCHEMAS_FILE)

    if (not currentHash or currentHash == lastHash) then continue end

    source = fs.readFile(SCHEMAS_FILE)

    table.clear(schemas)

    for annotation, name in source:gmatch(
        "%-%-@schema%-(%S+)%s*schemas%[%s*['\"](%w+)['\"]%s*%]"
    ) do
        table.insert(schemas, {
            name = name,
            kind = annotation,
        })
    end

    print("Change detected in schemas.luau — regenerating signals...")
    local success = pcall(function()
        fs.writeFile(OUT_CLIENT, generateFile(CLIENT_HEADER, clientGenerators))
        fs.writeFile(OUT_SERVER, generateFile(SERVER_HEADER, serverGenerators))
    end)

    if success then
        print("Signals regenerated successfully")
    else
        print("Error during generation")
    end

    lastHash = currentHash
    
end
