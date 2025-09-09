-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local moduleScripts = {
    AchievementUnlock = require(playerGui:FindFirstChild("AchievementUnlock", true)),
    Achievements = require(ReplicatedStorage.ModulesShared.Achievements)
}
local defaultAchievement = {
    Title = "Title",
    Desc = "Description",
    Reason = "Reason",
    Image = "rbxassetid://12309073114",
    Prize = {
        Revives = {
            Enabled = true,
            Amount = 1
        },
        Knobs = {
            Enabled = true,
            Amount = 100
        },
        Stardust = {
            Enabled = false,
            Amount = 20
        }
    }
}

-- Main
return function(info)
    info = (type(info) == "table") and info or {}
    for i, v in defaultAchievement do
        if info[i] == nil then
            info[i] = v
        end
    end
    local prize = playerGui.MainUI.AchievementsHolder.Achievement.Frame.Prize
    local stuff = moduleScripts.Achievements.SpecialQATester
    local old = stuff.GetInfo
    stuff.GetInfo = newcclosure(function() return info end)
    if info.Prize.Revives.Enabled then
        prize.Revives.Text = tostring(info.Prize.Revives.Amount)
        prize.Revives.Visible = true
        prize.RevivesIcon.Visible = true
    end
    if info.Prize.Knobs.Enabled then
        prize.Knobs.Text = tostring(info.Prize.Knobs.Amount)
        prize.Knobs.Visible = true
        prize.KnobsIcon.Visible = true
        end
    if info.Prize.Stardust.Enabled then
        prize.Stardust.Text = tostring(info.Prize.Stardust.Amount)
        prize.Stardust.Visible = true
        prize.StardustIcon.Visible = true
    end
    moduleScripts.AchievementUnlock(nil, stuff.Name)
    stuff.GetInfo = old
end