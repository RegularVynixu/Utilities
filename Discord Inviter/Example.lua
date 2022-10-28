local Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))()

-- Creates an interactable prompt
Inviter.Prompt({
    name = "your server name",
    invite = "your invite",
})


----- ALTERNATIVELY -----


-- Will skip the prompt and invite the user right away
Inviter.Join("your invite")
