local DoorReplication = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua"))()


-- Get current room
local currentRoom = workspace.CurrentRooms[game:GetService("ReplicatedStorage").GameData.LatestRoom.Value]


-- Replicate door
DoorReplication.ReplicateDoor(currentRoom, "Custom Key Name")
