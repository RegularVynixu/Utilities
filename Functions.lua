-- Services

local Players = game:GetService("Players")

-- Variables

local Plr = Players.LocalPlayer

local ModuleScripts = {}
local Functions = {
    IsClosure = is_synapse_function or iskrnlclosure or isexecutorclosure,
    SetIdentity = (syn and syn.set_thread_identity) or set_thread_identity or setthreadidentity or setthreadcontext,
    GetIdentity = (syn and syn.get_thread_identity) or get_thread_identity or getthreadidentity or getthreadcontext,
    Request = (syn and syn.request) or http_request or request,
    QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport,
    GetAsset = getsynasset or getcustomasset,
}

-- Misc Functions

function convertString(str)
    if str == "" then
        return ""
    
    elseif str:find("rbxassetid") or str:find("roblox.com") or tonumber(str) then
        local numberId = str:gsub("%D", "")

        return "rbxassetid://".. numberId

    elseif str:find("http") then
        local fileName = "customObject_".. tick().. ".txt"

        writefile(fileName, Functions.Request({Url = str, Method = "GET"}))

        return fileName
    else
        return Functions.GetAsset(str)
    end
end

-- Functions

Functions.GetPlayerByName = function(name)
    for _, v in next, Players:GetPlayers() do
        if v.Name:lower():find(name) or v.DisplayName:lower():find(name) then
            return v
        end
    end
end

Functions.LoadModule = function(name)
    for _, v in next, ModuleScripts do
        if v.Name == name then
            return require(v)
        end
    end
end

Functions.LoadCustomAsset = function(str)
    return convertString(str)
end

Functions.LoadCustomInstance = function(str)
    local converted = convertString(str)

    if converted ~= "" then
        return game:GetObjects(converted)[1]
    end
end

-- Scripts

for _, v in next, game:GetDescendants() do
    if v.ClassName == "ModuleScript" then
        table.insert(ModuleScripts, v)
    end
end

game.DescendantAdded:Connect(function(des)
    if des.ClassName == "ModuleScript" then
        table.insert(ModuleScripts, des)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player == plr then
        for _, v in next, listfiles("") do
            if v:find("customObject") then
                delfile(v)
            end
        end
    end
end)

for name, func in next, Functions do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end

return Functions
