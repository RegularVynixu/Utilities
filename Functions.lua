-- Services
local Players = game:GetService("Players")

-- Variables
local localPlayer = Players.LocalPlayer

local stuff = {
    set_identity = set_thread_identity or setthreadidentity,
    get_identity = get_thread_identity or getthreadidentity,
    request = http_request or request
}
local moduleScripts = {}

-- Functions
stuff.GetPlayerByName = function(name)
    for _, plr in Players:GetPlayers() do
        if plr.Name:lower():find(name) or plr.DisplayName:lower():find(name) then
            return plr
        end
    end
end

stuff.LoadModule = function(name)
    for _, ms in moduleScripts do
        if ms.Name == name then
            return require(ms)
        end
    end
end

stuff.LoadCustomAsset = function(path)
    if path ~= "" then
        if isfile(path) then
            return getcustomasset(path, true)
    
        elseif path:find("rbxassetid") or tonumber(path) then
            return "rbxassetid://".. path:match("%d+")
    
        elseif path:sub(1, 4) == "http" then
            local r = request({
                Url = path,
                Method = "GET"
            })
            if r ~= nil and r.Success == true then
                local fileName = ("customAsset_%s.txt"):format(tick())
                writefile(fileName, r.Body)
                local result = getcustomasset(fileName, true)
                delfile(fileName)
                return result
            else
                warn("Failed to load custom asset for: ".. path)
            end
        end
    end
end

stuff.LoadCustomInstance = function(path)
    if path ~= "" then
        local success, result = pcall(function()
            return game:GetObjects(LoadCustomAsset(path))[1]
        end)
        if success then
            return result
        else
            warn("Failed to load custom instance for: ".. path)
        end
    end
end

-- Main
for _, d in game:GetDescendants() do
    if d.ClassName == "ModuleScript" then
        moduleScripts[#moduleScripts + 1] = d
    end
end

for name, func in stuff do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end

game.DescendantAdded:Connect(function(d)
    if d.ClassName == "ModuleScript" then
        table.insert(moduleScripts, d)
    end
end)

return stuff
