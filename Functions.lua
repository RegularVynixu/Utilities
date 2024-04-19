-- Variables
local module = {}

-- Functions
module.LoadCustomAsset = function(url)
    if getcustomasset then
        if isfile(url) then
            return getcustomasset(url, true)
        elseif url:lower():sub(1, 4) == "http" then
            local fileName = `temp_{tick()}.txt`
            writefile(fileName, game:HttpGet(url))
            local result = getcustomasset(fileName, true)
            delfile(fileName)
            return result
        end
    else
        warn("Executor doesn't support 'getcustomasset', rbxassetid only.")
    end
    if url:find("rbxassetid") or tonumber(url) then
        return "rbxassetid://"..url:match("%d+")
    end
    warn("Failed to load custom asset for:\n"..url)
end

module.LoadCustomInstance = function(url)
    local success, result = pcall(function()
        return game:GetObjects(module.LoadCustomAsset(url))[1]
    end)
    if success then
        return result
    end
end

-- Main
for name, func in module do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end
return module
