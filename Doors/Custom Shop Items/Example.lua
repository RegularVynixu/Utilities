--[[

    NOTE: Custom shop items will NOT cost any real knobs

]]--

local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()


-- Create your tool here
local exampleTool = LoadCustomInstance("rbxassetid://11397433017")


-- Create custom shop item
CustomShop.CreateItem(exampleTool, {
    Title = "Example Item",
    Desc = "Example description",
    Image = "https://cdn.discordapp.com/attachments/1034486774627573821/1035460240352747541/ExampleImage.png",
    Price = 999,
    Stack = 1,
})
