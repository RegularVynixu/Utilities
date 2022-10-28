--[[

    NOTE: Custom shop items will NOT cost any real knobs

]]--

local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()

-- Create custom shop item
CustomShop:CreateItem({
    Title = "Example Item",
    Desc = "Example description",
    Image = "https://cdn.discordapp.com/attachments/1034486774627573821/1035460240352747541/ExampleImage.png",
    Price = 999,
    Stack = 1,
    ToolAssetId = "rbxassetid://11397433017", -- Your tool id here
}, function(tool)
    print(tool.Name.. " has been added into your inventory.")
end)
