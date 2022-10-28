--[[

    NOTE: Keep in mind that these are "fake" achievements and will NOT give you an in-game badge.

]]--

local Achievements = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Achievements/Source.lua"))()

-- Creates and displays your custom achievement
Achievements.Get({
    Title = "Example Achievement",
    Desc = "This is very cool.",
    Reason = "You executed the example script.",
    Image = "https://images.emojiterra.com/twitter/v13.1/512px/1f913.png",
})
