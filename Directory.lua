-- Services
local HttpService = game:GetService("HttpService")

-- Variables
local directory = {}

-- Functions
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

directory.Create = function(tree, fPath)
    fPath = fPath and fPath.."/" or ""
    local t = {}
    for i, v in tree do
        local tPath = fPath..(typeof(v) == "table" and i or v)
        t.Root = tPath
        createFolder(tPath)
        if typeof(v) == "table" then
            createBranch(t, v, tPath)
        end
        break
    end
    return t
end

directory.WriteConfig = function(fPath, data)
    local success = pcall(function()
        writefile(fPath, HttpService:JSONEncode(data))
    end)
    return success
end

directory.DecodeConfig = function(fPath)
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(fPath))
    end)
    return success, (success and result or {})
end

directory.GetNameFromDirectory = function(fPath, noExtension)
    local splt = fPath:split([[\]])
    local name = splt[#splt]
    if noExtension then
        local i = name:find("%.[^.]+$")
        if i then
            name = name:sub(1, i - 1)
        end
    end
    return name
end

-- Main
for i, v in directory do
    if typeof(v) == "function" then
        getgenv()[i] = v
    end
end

return directory
