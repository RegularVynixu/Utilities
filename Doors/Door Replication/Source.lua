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
    Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
}

local Assets = {
    Door = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Door%20Replication/Door.rbxm?raw=true"),
}

local DoorReplication = {}

-- Misc Functions

local function openDoor(doorTable, config)
    local model = doorTable.Model

    doorTable.Debug.OnDoorPreOpened()
    model:SetAttribute("Opened", true)

    if model:FindFirstChild("Lock") then
        -- Unlock visual

        model.Lock.UnlockPrompt.Enabled = false
        model.Lock.M_Thing.C0 = model.Lock.M_Thing.C0 * CFrame.Angles(0, math.rad(-45), 0)
        model.Hinge.Lock:Destroy()
        model.Lock.UnlockPrompt:Destroy()
    end

    -- Door opening visual

    if model:FindFirstChild("Light") then
        model.Light.Light.Color = Color3.fromRGB(197, 113, 88)
        model.Light.Light.Attachment.PointLight.Enabled = true
        model.Light.Light.Hit:Play()
    end
    
    model.Door.CanCollide = false
    model.Door.Open:Play()
    model.Hidden:Destroy()

    task.spawn(function()
        local knobC1 = model.Hinge.Knob.C1

        TS:Create(model.Hinge.Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {C1 = knobC1 * CFrame.Angles(0, 0, math.rad(-35))}):Play()
        task.wait(0.15)
        TS:Create(model.Hinge.Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {C1 = knobC1}):Play()
    end)

    TS:Create(model.Hinge, TweenInfo.new(config.SlamOpen and 0.15 or 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = model.Hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0)}):Play()

    -- Next room preparations

    local nextRoom = workspace.CurrentRooms:FindFirstChild(tonumber(model.Parent.Name) + 1)

    if nextRoom then
        for _, v in next, {"Assets", "Light_Fixtures"} do
            if nextRoom:FindFirstChild(v) then
                for _, v2 in next, nextRoom[v]:GetDescendants() do
                    if string.find(v2.ClassName, "Light") and not v2.Enabled then
                        v2.Enabled = true
                    end
                end
            end
        end
    end

    doorTable.Debug.OnDoorOpened()
end

-- Functions

DoorReplication.CreateDoor = function(config)
    local door = Assets.Door:Clone()
    door.Door.MaterialVariant = "PlywoodALT"
    door.Sign.MaterialVariant = "Plywood"

    if not config.Barricaded then
        door.Boards:Destroy()
        
        if not config.Locked then
            door.Lock:Destroy()
        end

        if config.Sign == false then
            door.Sign:Destroy()
            door.Gui:Destroy()
        end

        if config.Light == false then
            door.Light:Destroy()
        end
    else
        door.Lock:Destroy()
        door.Sign:Destroy()
        door.Gui:Destroy()
    end

    return door
end

DoorReplication.ReplicateDoor = function(room, config)
    -- Door table

    local doorTable = {
        Debug = {
            OnDoorPreOpened = function() end,
            OnDoorOpened = function() end,
        },
    }

    -- Pre-configs setup

    for _, v in next, {"Key", "Lockpick"} do
        if not table.find(config.CustomKeyNames, v) then
            table.insert(config.CustomKeyNames, v)
        end
    end

    -- Door replication

    local door = room:WaitForChild("Door", 1)

    if door then
        local repDoor = DoorReplication.CreateDoor({
            Locked = room:WaitForChild("Assets"):WaitForChild("KeyObtain", 0.3) ~= nil,
            Sign = true,
            Light = true,
            Barricaded = false,
        })

        repDoor:SetPrimaryPartCFrame(door.PrimaryPart.CFrame)
        repDoor.Parent = room
        
        doorTable.Model = repDoor

        -- Sign

        local signText = ""
        for _ = #tostring(room.Name + 1), 3 do
            signText = signText.. "0"
        end
    
        for _, v in next, repDoor.Gui:GetDescendants() do
            if v.ClassName == "TextLabel" then
                v.Text = signText.. tostring(room.Name + 1)
            end
        end

        -- Guiding light

        if config.GuidingLight ~= false and room:GetAttribute("IsDark") then
            task.spawn(function()
                if not door.Door.LightAttach.HelpLight.Enabled then
                    task.wait(15)
                end

                if repDoor.Parent and not repDoor:GetAttribute("Opened") then
                    repDoor.Door.LightAttach.HelpLight.Enabled = true
                    repDoor.Door.LightAttach.HelpParticle.Enabled = true

                    TS:Create(repDoor.Door.LightAttach.HelpLight, TweenInfo.new(2), {Brightness = 0.5}):Play()
                end
            end)
        end

        -- Connections

        local connections = {}

        if repDoor:FindFirstChild("Lock") then
            connections.unlockBegan = repDoor.Lock.UnlockPrompt.PromptButtonHoldBegan:Connect(function()
                for _, v in next, config.CustomKeyNames do
                    local key = Char:FindFirstChild(v)

                    if key and key:FindFirstChild("Animations") and key.Animations:FindFirstChild("use") then
                        Hum:LoadAnimation(key.Animations.use):Play()
                        return
                    end
                end

                firesignal(ReSt.Bricks.Caption.OnClientEvent, "You need a key!", true)
            end)

            connections.unlockTriggered = repDoor.Lock.UnlockPrompt.Triggered:Connect(function()
                for _, v in next, connections do
                    v:Disconnect()
                end

                for _, v in next, config.CustomKeyNames do
                    local key = Char:FindFirstChild(v)

                    if key then
                        if config.DestroyKey ~= false then
                            key:Destroy()
                        end

                        openDoor(doorTable, config)
                        break
                    end
                end
            end)
        else
            while repDoor.Parent and Root do
                if (Root.Position - repDoor.PrimaryPart.Position).Magnitude <= 15 then
                    openDoor(doorTable, config)
                    break
                end

                task.wait()
            end
        end

        door:Destroy()

        -- Return
        
        return doorTable
    else
        warn("Failure - Could not find door in room:", room)
    end
end

-- Scripts

return DoorReplication
