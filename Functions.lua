-- Services

local Players = game:GetService("Players")

-- Variables

local Plr = Players.LocalPlayer

local Functions = {
    IsClosure = is_synapse_function or iskrnlclosure or isexecutorclosure,
    SetIdentity = (syn and syn.set_thread_identity) or set_thread_identity or setthreadidentity or setthreadcontext,
    GetIdentity = (syn and syn.get_thread_identity) or get_thread_identity or getthreadidentity or getthreadcontext,
    Request = (syn and syn.request) or http_request or request,
    QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport,
    GetAsset = getsynasset or getcustomasset,
}
local ModuleScripts = {}

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
    if str == "" then
        return ""

    elseif str:find("rbxassetid://") or str:find("roblox.com") or tonumber(str) then
        local numberId = str:gsub("%D", "")

        return "rbxassetid://".. numberId
    else
        if isfile(str) then -- is local file
            return Functions.GetAsset(str)
        else
            local fileName = "customObject_".. tick().. ".txt"

            writefile(fileName, Functions.Request({Url = str, Method = "GET"}).Body)

            return Functions.GetAsset(fileName)
        end
    end
end

Functions.LoadCustomInstance = function(str)
    if str ~= "" then
        if str:find("rbxassetid://") or str:find("roblox.com") or tonumber(str) then
            local numberId = str:gsub("%D", "")

            return game:GetObjects("rbxassetid://".. numberId)[1]
        else
            if isfile(str) then -- is local file
                return game:GetObjects(Functions.GetAsset(str))[1]
            else
                local fileName = "customObject_".. tick().. ".txt"

                writefile(fileName, Functions.Request({Url = str, Method = "GET"}).Body)

                return game:GetObjects(Functions.GetAsset(fileName))[1]
            end
        end
    end
end

-- Scripts

for _, v in next, game:GetDescendants() do
    if v.ClassName == "ModuleScript" then
        table.insert(ModuleScripts, v)
    end
end

for name, func in next, Functions do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end

game.DescendantAdded:Connect(function(des)
    if des.ClassName == "ModuleScript" then
        table.insert(ModuleScripts, des)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player == Plr then
        for _, v in next, listfiles("") do
            if v:find("customObject") then
                delfile(v)
            end
        end
    end
end)

return Functions
