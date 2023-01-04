-- Services

local HS = game:GetService("HttpService")

-- Variables

local Directory = {}

-- Misc Functions

local function createFolder(directory)
    if not isfolder(directory) then
        makefolder(directory)
    end
end

local function createBranch(tree, branch, directory)
    for i, v in next, branch do
        local branchName = typeof(v) == "table" and i or v
        local branchDirectory = (directory or "").. "/".. branchName
        
        createFolder(branchDirectory)
        tree[branchName] = branchDirectory
        
        if typeof(v) == "table" then
            createBranch(tree, v, branchDirectory)
        end
    end
end

-- Functions

Directory.Create = function(tree, directory)
    local newTree = {}

    for i, v in next, tree do
        local treeDirectory = (directory and directory.. "/" or "").. (typeof(v) == "table" and i or v)
        
        createFolder(treeDirectory)
        newTree.Root = treeDirectory
        
        if typeof(v) == "table" then
            createBranch(newTree, v, treeDirectory)
        end
    end

    return newTree
end

Directory.WriteConfig = function(directory, data)
    local success = pcall(function()
        writefile(directory, HS:JSONEncode(data))
    end)

    return success
end

Directory.DecodeConfig = function(directory)
    local success, dConfig = pcall(function()
        return HS:JSONDecode(readfile(directory))
    end)

    return success, success and dConfig or {}
end

Directory.GetNameFromDirectory = function(directory, noExtension)
    local splt = directory:split([[\]])
    local name = splt[#splt]
    
    if noExtension then
        local splt2 = name:split(".")
        
        if #splt2 > 1 then
            name = splt2[1]
        end
    end
    
    return name
end

return Directory
