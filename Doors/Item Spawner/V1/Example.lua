---====== Define spawner ======---

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Item%20Spawner/V1/Source.lua"))()

---====== Create item ======---

local tool = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Item%20Spawner/Assets/Template%20Item.rbxm?raw=true")

tool.TextureId = LoadCustomAsset("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Item%20Spawner/Assets/Template_Item.png")

local item = spawner.Create({
    Item = {
        Name = "Example Item",
        Asset = tool,
        DestroyOnPickup = false,
        PickupOnTouch = true
    },
    Prompt = {
        Range = 7,
        Duration = 0,
        LineOfSight = false
    },
    Locations = {
        Dresser = {
            Enabled = true, Offset = CFrame.new()
        },
        Drawer = {
            Enabled = true, Offset = CFrame.new()
        },
        Table = {
            Enabled = true, Offset = CFrame.new()
        },
        Chest = {
            Enabled = true, Offset = CFrame.new()
        },
        Bed = {
            Enabled = true, Offset = CFrame.new()
        },
        Floor = {
            Enabled = true, Offset = CFrame.new()
        },
        Fireplace = {
            Enabled = true, Offset = CFrame.new()
        },
        Doorframe = {
            Enabled = true, Offset = CFrame.new()
        },
        Wall = {
            Enabled = true, Offset = CFrame.new()
        }
    }
})

---====== Debug item ======---

item:SetCallback("OnPickedUp", function()
    print("Item picked up!")
end)

item:SetCallback("OnEquipped", function()
    print("Item equipped!")
end)

item:SetCallback("OnActivated", function()
    print("Item activated!")
end)

item:SetCallback("OnUnequipped", function()
    print("Item unequipped!")
end)

---====== Spawn item ======---

local currentRoomIndex = game:GetService("Players").LocalPlayer:GetAttribute("CurrentRoom") -- current room number index
local currentRoom = workspace.CurrentRooms[currentRoomIndex] -- current room instance

item:Spawn(currentRoom)
