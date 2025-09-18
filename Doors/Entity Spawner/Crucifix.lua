local Players = game:GetService("Players")
local player = Players.LocalPlayer
local backpack = player.Backpack

loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
local crucifix = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/raw/main/Doors/Item%20Spawner/Assets/Crucifix.rbxm")
crucifix.Name = "Crucifix"
crucifix.Parent = backpack
