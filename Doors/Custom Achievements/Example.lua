---====== Load achievement giver ======---
local achievementGiver = loadstring(game:HttpGet("https://raw.githubusercontent.com/Focuslol666/Utilities/refs/heads/patch-1/Doors/Custom%20Achievements/Source.lua"))()

---====== Display achievement ======---
achievementGiver({
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
})
