---====== Load Discord inviter ======---
local discordInviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()

---====== Display invite prompt ======---
discordInviter.Prompt({
    name = "Roblox",
    invite = "https://discord.com/invite/roblox"
})
