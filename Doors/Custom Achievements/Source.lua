--[[
    This loadstring for DOORS Custom Achievements is now deprecated.
    Please use the new loadstring below to remain up to date:

    https://raw.githubusercontent.com/RegularVynixu/DOORS-Custom-Achievements/main/init.luau
]]--

local CustomAchievements = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/DOORS-Custom-Achievements/main/init.luau"))()

return function(info: any)
    CustomAchievements:Grant({
        Identifier = "TestAchievement",
        Title = info.Title,
        Desc = info.Desc,
        Reason = info.Reason,
        Image = info.Image
    }, {
        CheckOwned = false,
        Remember = false
    })
end