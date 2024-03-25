-- Services
local HttpService = game:GetService("HttpService")

-- Variables
local directory = {}

-- Misc Functions
local function createFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

local function createBranch(tree, branch, path)
    for i, v in branch do
        if type(v) == "table" then
            createBranch(tree, v, path .. "/" .. i)
        else
            createFolder(path .. "/" .. i)
        end
    end
end

-- Functions
directory.Create = function(tree, fPath)
    fPath = fPath or ""
    local t = {}
    for i, v in tree do
        if type(v) == "table" then
            createBranch(t, v, fPath .. "/" .. i)
        else
            createFolder(fPath .. "/" .. i)
        end
    end
    return t
end

-- Services
local HttpService = game:GetService("HttpService")

-- Variables
local directory = {}

-- Misc Functions

local function createFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

local function createBranch(tree, branch, bPath)
    for i, v in branch do
        local name = (typeof(v) == "table") and i or v
        bPath = (bPath or "").."/"..name
        
        createFolder(bPath)
        tree[name] = bPath
        
        if typeof(v) == "table" then
            createBranch(tree, v, bPath)
        end
    end
end

-- Functions

directory.Create = function(tree, fPath)
    fPath = fPath and fPath.."/" or ""
    local t = {}
    for i, v in tree do
        local tPath = fPath..((typeof(v) == "table") and i or v)
        t.Root = tPath
        createFolder(tPath)
        if typeof(v) == "table" then
            createBranch(t, v, tPath)
        end
        break
    end
    return t
end

directory.WriteConfig = function(fPath, content)
    local success = pcall(function()
        writefile(fPath, HttpService:JSONEncode(content))
    end)
    return success
end

directory.DecodeConfig = function(fPath)
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(directory))
    end)
    return success, (success and result or {})
end

directory.GetNameFromDirectory = function(fPath, noExtension)
    local splt = fPath:split([[\]])
    local name = splt[#splt]
    
    if noExtension then
        local splt2 = name:split(".")
        if #splt2 > 1 then
            name = splt2[1]
        end
    end
    return name
end

return directory
