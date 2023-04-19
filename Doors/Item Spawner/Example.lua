---====== Define spawner ======---
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Item%20Spawner/Source.lua"))();

---====== Create item ======---
local currentRoomIndex = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value; -- Get index of the current room

local item = spawner.createItem({
    Url = "https://github.com/RegularVynixu/Utilities/blob/main/Doors/Item%20Spawner/Assets/Template%20Item.rbxm?raw=true";
    Spawning = {
        Offset = CFrame.new();
        MinRoom = currentRoomIndex; -- Set min room index to current room's index
        MaxRoom = currentRoomIndex; -- Set max room index to current room's index
        Chance = 100;
    };
    Locations = {
        Drawers = true;
        Tables = true;
        Chests = true;
        Floor = true;
    };
    Prompt = {
        Range = 7;
        Duration = 0;
    };
});

---====== Debug ======---
item.Debug.OnSpawned = function()
    print("Item spawned:", item);
end;

item.Debug.OnPickedUp = function()
    print("Item picked up:", item);
end;

item.Debug.OnEquipped = function()
    print("Item equipped:", item);
end;

item.Debug.OnActivated = function()
    print("Item activated:", item);
end;

item.Debug.OnUnequipped = function()
    print("Item unequipped:", item);
end;

item.Debug.OnEnteredItemRoom = function(room)
    print("Entered room:", room, "of item:", item);
end;

---====== Spawn item ======---
spawner.spawnItem(item);
