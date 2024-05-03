-- Loader
local module = loadstring("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/ESP/Better_ESP/Source.lua")()

-- Services
local Players = game:GetService("Players")

-- Example
for _, plr in Players:GetPlayers() do
    if plr ~= Players.LocalPlayer and plr.Character then
        local character = plr.Character
        local humanoid = character:WaitForChild("Humanoid")
        local rootPart = character:WaitForChild("HumanoidRootPart")

        module:Add(rootPart, {
            Name = plr.Name,
            Color = Color3.fromHSV(math.random(), 1, 1),
            HighlightFocus = character,
        }, {
            Health = function()
                return humanoid.Health, humanoid.MaxHealth -- This callback is used to display health, maxHealth
            end
        })
    end
end