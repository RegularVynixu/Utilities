-- Services

local Players = game:GetService("Players")
local ReSt = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer

local SelfModules = {
    Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
}
local ModuleScripts = {
    Achievements = require(ReSt.Achievements),
    AchievementUnlock = require(Plr.PlayerGui.MainUI.Initiator.Main_Lobby.RemoteListener.Modules.AchievementUnlock)
}

local Achievements = {}

-- Functions

Achievements.Get = function(data)
    task.spawn(function()
        local frame = Plr.PlayerGui.MainUI.AchievementsHolder.Achievement:Clone()

        frame.Name = "LiveAchievement"
        frame.Frame.Details.Title.Text = data.Title
        frame.Frame.Details.Desc.Text = data.Desc
        frame.Frame.Details.Reason.Text = data.Reason
        frame.Frame.ImageLabel.Image = LoadCustomAsset(data.Image)
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Frame.Position = UDim2.new(1.1, 0, 0, 0)
        frame.Visible = true
        frame.Parent = Plr.PlayerGui.MainUI.AchievementsHolder
    
        frame.Sound:Play()
        frame:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.8, true)
        task.wait(0.8)
        frame.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
        TS:Create(frame.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 1 }):Play()
        task.wait(8)
        frame.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
        task.wait(0.5)
        frame:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- Scripts

return Achievements
