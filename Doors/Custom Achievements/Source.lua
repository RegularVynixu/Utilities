-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local moduleScripts = {
    AchievementUnlock = require(playerGui:FindFirstChild("AchievementUnlock", true)),
    Achievements = require(ReplicatedStorage.Achievements)
}
local defaultAchievement = {
    Title = "Title",
    Desc = "Description",
    Reason = "Reason",
    Image = "rbxassetid://12309073114"
}

-- Main
return function(info)
    info = (type(info) == "table") and info or {}
    for i, v in defaultAchievement do
        if info[i] == nil then
            info[i] = v
        end
    end
    local stuff = moduleScripts.Achievements.SpecialQATester
    local old = stuff.GetInfo
    stuff.GetInfo = newcclosure(function() return info end)
    moduleScripts.AchievementUnlock(nil, stuff.Name)
    stuff.GetInfo = old
end
