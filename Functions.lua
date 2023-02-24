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

-- Misc Functions

local function convertToAsset(str)
    if isfile(str) then
        return Functions.GetAsset(str)
        
    elseif str:find("rbxassetid") or tonumber(str) then
        local numberId = str:gsub("%D", "")
        return "rbxassetid://".. numberId
        
    elseif str:find("http") then
        local req = Functions.Request({Url=str, Method="GET"})
        
        if req.Success then
            local name = "customObject_".. tick().. ".txt"
            writefile(name, req.Body)
            return Functions.GetAsset(name)
        end
    end

    return str
end

-- Functions

Functions.GetPlayerByName = function(name)
    for _, plr in next, Players:GetPlayers() do
        if plr.Name:lower():find(name) or plr.DisplayName:lower():find(name) then
            return plr
        end
    end
end

Functions.LoadModule = function(name)
    for _, ms in next, ModuleScripts do
        if ms.Name == name then
            return require(ms)
        end
    end
end

Functions.LoadCustomAsset = function(str)
    if str == "" then
        return ""
    end

    return convertToAsset(str)
end

Functions.LoadCustomInstance = function(str)
    if str ~= "" then
        local asset = convertToAsset(str)
        local success, result = pcall(function()
            return game:GetObjects(asset)[1]
        end)
    
        if success then
            return result
        end
    end

    warn("Something went wrong attempting to load custom instance")
end

-- Scripts

for _, des in next, game:GetDescendants() do
    if des.ClassName == "ModuleScript" then
        table.insert(ModuleScripts, des)
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
        for _, file in next, listfiles("") do
            if file:find("customObject") then
                delfile(file)
            end
        end
    end
end)

return Functions
