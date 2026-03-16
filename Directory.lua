-- \\ Services // --

local HttpService = game:GetService("HttpService")

-- \\ Variables // --

local Module = {}

-- \\ Functions // --

local function CreateBranch(tree: any, branch: any, parentPath: string)
    for i, v in branch do
        local name = (typeof(v) == "table") and i or v
        local path = (parentPath and parentPath.."/" or "")..name

        makefolder(path)
        tree[name] = path

        if typeof(v) == "table" then
            CreateBranch(tree, v, path)
        end
    end
end

-- \\ Main // --

Module.Create = function(tree: any, path: string?)
    path = typeof(path) == "string" and path.."/" or ""
    local t = {}

    for i, v in tree do
        local name = (typeof(v) == "table") and i or v
        local rootPath = path..name

        t.Root = rootPath
        makefolder(rootPath)

        if typeof(v) == "table" then
            CreateBranch(t, v, rootPath)
        end

        break
    end

    return t
end

Module.WriteConfig = function(path: string, data: any): boolean
    local success = pcall(function()
        writefile(path, HttpService:JSONEncode(data))
    end)
    return success
end

Module.DecodeConfig = function(path: string): (boolean, any)
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    return success, success and result or {}
end

Module.GetFileName = function(path: string, noExtension: boolean): string
    local name = path:match("[^/\\]+$") or path
    if noExtension then
        name = name:gsub("%.[^.]+$", "")
    end
    return name
end

Module.GetNameFromDirectory = Module.GetFileName

for i, v in Module do
    if typeof(v) == "function" then
        getgenv()[i] = v
    end
end

return Module