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
        Enabled = true,
        Revives = 1,
        Knobs = 100,
        Stardust = 20
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
    if info.Prize.Enabled then
        if info.Prize.Revives > 0 then
            prize.Revives.Text = tostring(info.Prize.Revives)
            prize.Revives.Visible = true
            prize.RevivesIcon.Visible = true
        else
            prize.Revives.Visible = false
            prize.RevivesIcon.Visible = false
        end
        if info.Prize.Knobs > 0 then
            prize.Knobs.Text = tostring(info.Prize.Knobs)
            prize.Knobs.Visible = true
            prize.KnobsIcon.Visible = true
        else
            prize.Knobs.Visible = false
            prize.KnobsIcon.Visible = false
        end
        if info.Prize.Stardust > 0 then
            prize.Stardust.Text = tostring(info.Prize.Stardust)
            prize.Stardust.Visible = true
            prize.StardustIcon.Visible = true
        else
            prize.Stardust.Visible = false
            prize.StardustIcon.Visible = false
        end
    end
    moduleScripts.AchievementUnlock(nil, stuff.Name)
    stuff.GetInfo = old
end