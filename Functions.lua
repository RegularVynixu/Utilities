-- Services

local Players = game:GetService("Players")

-- Variables

local Plr = Players.LocalPlayer

local StoredModules = {}

-- Functions

local functions; functions = {
    IsClosure = is_synapse_function or iskrnlclosure or isexecutorclosure,
    SetIdentity = (syn and syn.set_thread_identity) or set_thread_identity or setthreadidentity or setthreadcontext,
    GetIdentity = (syn and syn.get_thread_identity) or get_thread_identity or getthreadidentity or getthreadcontext,
    Request = (syn and syn.request) or http_request or request,
    QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport,
    GetAsset = getsynasset or getcustomasset,
    -----
    LoadModule = function(name)
        for _, v in next, StoredModules do
            if v.Name == name then
                return require(v)
            end
        end
    end,
    GetPlayerByName = function(name)
        for _, v in next, game:GetService("Players"):GetPlayers() do
            if string.find(string.lower(v.Name), string.lower(name)) or string.find(string.lower(v.DisplayName), string.lower(name)) then
                return v
            end
        end
    end,
    LoadCustomAsset = function(url, rDelay)
        if string.find(url, "rbxassetid://") or tonumber(url) then
            local assetId = string.gsub(url, "%D", "")

            return "rbxassetid://".. assetId
        else
            local fileName = "customAsset_".. tick().. ".txt"

            writefile(fileName, functions.Request({Url = url, Method = "GET"}).Body)

            return functions.GetAsset(fileName)
        end
    end,
    LoadCustomInstance = function(url)
        if string.find(url, "rbxassetid://") or string.find(url, "roblox.com") or tonumber(url) then
            local assetId = string.gsub(url, "%D", "")

            return game:GetObjects("rbxassetid://".. assetId)[1]
        else
            local fileName = "customInstance_".. tick().. ".txt"
            local instance = nil

            writefile(fileName, game:HttpGet(url))
            instance = game:GetObjects(functions.GetAsset(fileName))[1]
            delfile(fileName)

            return instance
        end
    end,
}

-- Scripts

Players.PlayerRemoving:Connect(function(p)
    if p == Plr then
        for _, v in next, listfiles("") do
            if string.find(v, "customAsset") or string.find(v, "customInstance") then
                delfile(v)
            end
        end
    end
end)

for _, v in next, game:GetDescendants() do
    if v.ClassName == "ModuleScript" then
        StoredModules[#StoredModules + 1] = v
    end
end

for i, v in next, functions do
    if typeof(v) == "function" then
        getgenv()[i] = v
    end
end

return functions
