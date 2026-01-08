-- gen_modules.lua
-- run with: lune gen_modules.lua

local fs = require("@lune/fs")
local task = require("@lune/task")

--------------------------------------------------
-- Paths
--------------------------------------------------

--local OUT_FILE = path.join(ROOT, "Modules.lua")

-- path: hash
local modules = { 
    ['./src/ServerScriptService/Interfaces/Modules.luau'] = 123,
    ['./src/ReplicatedStorage/Interfaces/Modules.luau'] = 123,
} :: {
    [string]: number
}

--------------------------------------------------
-- Utilities
--------------------------------------------------

local function isLuaFile(file: string)
    return file:sub(-5) == ".luau"
end

local function isInterfaceFile(file: string)
    return isLuaFile(file)
        and file ~= "Modules.luau"
end

local function publicName(moduleName: string)
    -- ITestComponent -> TestComponent
    return moduleName:gsub("^I", "")
end

--------------------------------------------------
-- Scan directory
--------------------------------------------------

--local files = fs.readDir('/src')

---@type { module: string, public: string }[]

type interfaces = {{
        module: string, 
        public: string
    }}

local function scanDirectory(files: {string})
    local interfaces = {} :: interfaces

    for _, file in ipairs(files) do
        if isInterfaceFile(file) then
            local moduleName = file:gsub("%.luau$", "")
            table.insert(interfaces, {
                module = moduleName,
                public = publicName(moduleName),
            })
        end
    end

    return interfaces
end


--------------------------------------------------
-- Generate requires
--------------------------------------------------

local function generateRequires(interfaces: interfaces)
    local requires = {}

    for _, iface in ipairs(interfaces) do
        table.insert(
            requires,
            string.format(
                "local %s = require(script.Parent.%s)",
                iface.module,
                iface.module
            )
        )
    end

    return requires
end

--------------------------------------------------
-- Generate Types
--------------------------------------------------

local function generateTypes(interfaces: interfaces)
    local typesLines = {}

    for _, iface in ipairs(interfaces) do
        table.insert(
            typesLines,
            string.format(
                "    %s: %s.Main,",
                iface.public,
                iface.module
            )
        )
    end

    return typesLines
end


--------------------------------------------------
-- Generate return map
--------------------------------------------------

local function generateReturnMap(interfaces: interfaces, separator: string)
    local returnLines = {}

    for _, iface in ipairs(interfaces) do
        table.insert(
            returnLines,
            string.format(
                "    %s %s '%s',",
                iface.public,
                separator,
                iface.public
            )
        )
    end
    
    return returnLines
end

--------------------------------------------------
-- Emit file
--------------------------------------------------

local function generateFile(file: string)
    local interfaces = scanDirectory(fs.readDir(file..'/../'))

    local requires = generateRequires(interfaces)
    local typesLines = generateTypes(interfaces)

    local returnLines = generateReturnMap(interfaces, '=')
    local returnTypes = generateReturnMap(interfaces, ':')

    local output = table.concat({
        "-- AUTO-GENERATED. DO NOT EDIT.",
        "",
        "local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
        "",
        "local types = require(ReplicatedStorage.Utilities.Container.types)",
        table.concat(requires, "\n"),
        "",
        "export type Class<class=any, inject=any> =",
        "    class & types.InjectedClass<inject, types.filterModuleTypes<Types, inject>>",
        "",
        "export type Types = {",
        table.concat(typesLines, "\n"),
        "}",
        "",
        "return {",
        table.concat(returnLines, "\n"),
        "} :: {",
        table.concat(returnTypes, "\n"),
        "}",
        "",
    }, "\n")

    fs.writeFile(file, output)
end

--------------------------------------------------
-- Main watcher loop
--------------------------------------------------

print("Watching interfaces for changes...")

while task.wait(5) do

    local isBroken = false
    local wereChanges = false

    for module, lastHash in pairs(modules) do 
        local currentHash = #fs.readDir(module..'/../')
        if (not currentHash or currentHash == lastHash) then continue end

        wereChanges = true

        print(`Change detected in {module} — regenerating interfaces...`)
        local success = pcall(function()
            generateFile(module)
        end)

        if (not success) then isBroken = true end
        modules[module] = currentHash
    end

    if (not wereChanges) then continue end

    if isBroken then
        print("Error during generation")
    else
        print("Modules regenerated successfully")
    end
    
end


