local DoorReplication = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Door%20Replication/Source.lua"))()


-- Get current room
local room = workspace.CurrentRooms[game:GetService("ReplicatedStorage").GameData.LatestRoom.Value]


-- Replicate door
local replicatedDoor = DoorReplication.ReplicateDoor(room, {
    CustomKeyName = "CursedKey",
    DestroyKey = false,
})


-- Debug features [advanced]
replicatedDoor.Debug.OnDoorOpened = function(doorTable)
    warn("Door", doorTable.Model, "has opened")
end
