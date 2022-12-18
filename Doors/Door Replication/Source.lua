-- Services

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local ReSt = game:GetService("ReplicatedStorage")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local Root = Char:WaitForChild("HumanoidRootPart")

local SelfModules = {
    Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
}
local Assets = {
    Door = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Door%20Replication/Door.rbxm?raw=true")
}

local DoorReplicator = {}

-- Misc Functions

function openDoor(doorTable)
    task.spawn(function()
        local model = doorTable.Model
        local config = doorTable.Config
        local debug = doorTable.Debug
    
        task.spawn(debug.OnDoorPreOpened)
    
        if model:FindFirstChild("Lock") then
            model.Lock.UnlockPrompt.Enabled = false
            model.Lock.M_Thing.C0 = model.Lock.M_Thing.C0 * CFrame.Angles(0, math.rad(-45), 0)
            model.Hinge.Lock:Destroy()
        end
    
        if model:FindFirstChild("Light") then
            model.Light.Color = Color3.fromRGB(197, 113, 88)
            model.Light.Attachment.PointLight.Enabled = true
            model.Light.Hit:Play()
        end
        
        model.Door.CanCollide = false
        model.Door[config.SlamOpen and "SlamOpen" or "Open"]:Play()
        model.Hidden:Destroy()
    
        task.spawn(function()
            local knobC1 = model.Hinge.Knob.C1
    
            TS:Create(model.Hinge.Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                C1 = knobC1 * CFrame.Angles(0, 0, math.rad(-35))
            }):Play()
    
            task.wait(0.15)
    
            TS:Create(model.Hinge.Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                C1 = knobC1
            }):Play()
        end)
    
        local duration = config.SlamOpen and 0.15 or 0.75
    
        TS:Create(model.Hinge, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            CFrame = model.Hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0)
        }):Play()

        local nextRoom = workspace.CurrentRooms:WaitForChild(ReSt.GameData.LatestRoom.Value + 1, 1)

        if nextRoom then
            for _, v in next, nextRoom:WaitForChild("Assets"):WaitForChild("Light_Fixtures"):GetDescendants() do
                if v:IsA("Light") then
                    v.Enabled = true
                end
            end
        end

        task.wait(duration)
        task.spawn(debug.OnDoorOpened)
    end)
end

-- Functions

DoorReplicator.CreateDoor = function(config)
    local door = Assets.Door:Clone()
    door.Door.MaterialVariant = "PlywoodALT"
    door.Sign.MaterialVariant = "Plywood"
    door:SetAttribute("IsFakeDoor", true)

    if config.Barricaded then
        door.Lock:Destroy()
        door.Light:Destroy()
        door.Sign:Destroy()
        door.Gui:Destroy()
    else
        door.Boards:Destroy()

        if not config.Locked then
            door.Lock:Destroy()
        end

        if config.Sign == false then
            door.Sign:Destroy()

        elseif config.RoomIndex then
            local text = ""
            
            for _ = 1, 4 - #tostring(config.RoomIndex) do
                text ..= "0"
            end
            text ..= config.RoomIndex + 1
            
            for _, v in next, door.Gui:GetDescendants() do
                if v.ClassName == "TextLabel" then
                    v.Text = text
                end
            end
        end

        if config.Light == false then
            door.Light:Destroy()
        end
    end

    return door
end

DoorReplicator.ReplicateDoor = function(door, config)
    assert(door:FindFirstChild("Hinge"), "Door does not have a hinge")
    assert(not door:FindFirstChild("Boards"), "Cannot replicate a barricaded door")

    for _, v in next, {"Key", "Lockpick"} do
        if not table.find(config.CustomKeyNames, v) then
            table.insert(config.CustomKeyNames, v)
        end
    end

    local doorTable = {
        Model = door,
        Config = config,
        Debug = {
            OnDoorPreOpened = function() end,
            OnDoorOpened = function() end
        }
    }

    if door:FindFirstChild("Lock") then
        local unlockBegan; unlockBegan = door.Lock.UnlockPrompt.PromptButtonHoldBegan:Connect(function()
            for _, v in next, config.CustomKeyNames do
                local key = Char:FindFirstChild(v)

                if key then
                    if key:FindFirstChild("Animations") and key.Animations:FindFirstChild("use") then
                        Hum:LoadAnimation(key.Animations.use):Play()
                    end

                    return
                end
            end
            
            firesignal(ReSt.Bricks.Caption.OnClientEvent, "You need a key!")
        end)

        local unlockTriggered; unlockTriggered = door.Lock.UnlockPrompt.Triggered:Connect(function()
            for _, v in next, config.CustomKeyNames do
                local key = Char:FindFirstChild(v)

                if key then
                    unlockBegan:Disconnect()
                    unlockTriggered:Disconnect()

                    if config.DestroyKey ~= false then
                        key:Destroy()
                    end
                    
                    openDoor(doorTable)
                end
            end
        end)
    else
        task.spawn(function()
            while doorTable.Model.Parent and Root do
                if (Root.Position - doorTable.Model.Door.Position).Magnitude <= doorTable.Config.DetectionRange then
                    openDoor(doorTable)
    
                    break
                end
    
                task.wait()
            end
        end)
    end

    return doorTable
end

-- Scripts

return DoorReplicator
