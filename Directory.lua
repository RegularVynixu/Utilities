-- Variables

local Directory = {}

-- Misc Functions

local function createFolder(directory)
    if not isfolder(directory) then
        makefolder(directory)
    end
end

local function createBranch(branch, directory)
    for i, v in next, branch do
        local branchDirectory = (directory or "").. "/".. (typeof(v) == "table" and i or v)
        
        createFolder(branchDirectory)
        
        if typeof(v) == "table" then
            createBranch(v, branchDirectory)
        end
    end
end

-- Functions

Directory.Create = function(tree, directory)
    for i, v in next, tree do
        local treeDirectory = (directory or "").. "/".. (typeof(v) == "table" and i or v)
        
        createFolder(treeDirectory)
        
        if typeof(v) == "table" then
            createBranch(v, treeDirectory)
        end
    end
end

Directory.DecodeConfig = function(directory)
    local success, dConfig = pcall(function()
        return HS:JSONDecode(readfile(directory))
    end)

    return success, success and dConfig or {}
end

return Directory
