-- Services

local Players = game:GetService("Players")
local ReSt = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local StorageFolder = Instance.new("Folder")
StorageFolder.Name = "Storage"
StorageFolder.Parent = game

local SelfModules = {
    Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
}
local Assets = {
    FakeDoor = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Door%20Replication/FakeDoor.rbxm?raw=true"),
}

local DoorReplication = {}

-- Misc Functions

local function openFakeDoor(doorTable)
    local model = doorTable.Model

    model:SetAttribute("IsOpen", true)
    doorTable.Debug.OnDoorPreOpened(doorTable)

    if model:FindFirstChild("Lock") then
        -- Unlock visual

        model.Lock.UnlockPrompt.Enabled = false
        model.Lock.M_Thing.C0 = model.Lock.M_Thing.C0 * CFrame.Angles(0, math.rad(-45), 0)
        model.Hinge.Lock:Destroy()
        model.Lock.UnlockPrompt:Destroy()
    end

    -- Door opening visual

    model.Door.CanCollide = false
    model.Light.Color = Color3.fromRGB(197, 113, 88)
    model.Light.Attachment.PointLight.Enabled = true
    model.Light.Hit:Play()
    model.Door.Open:Play()

    task.spawn(function()
        local knobC1 = model.Hinge.Knob.C1

        TS:Create(model.Hinge.Knob, TweenInfo.new(0.175, Enum.EasingStyle.Quad), {C1 = knobC1 * CFrame.Angles(0, 0, math.rad(-35))}):Play()
        task.wait(0.175)
        TS:Create(model.Hinge.Knob, TweenInfo.new(0.175, Enum.EasingStyle.Quad), {C1 = knobC1}):Play()
    end)

    TS:Create(model.Hinge, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = model.Hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0)}):Play()

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

    doorTable.Debug.OnDoorOpened(doorTable)
end

-- Functions

DoorReplication.ReplicateDoor = function(room, config)
    -- Door table

    config.CustomKeyName = typeof(config.CustomKeyName) == "string" and config.CustomKeyName or "Key"

    local doorTable = {
        Model = fakeDoor,
        Debug = {
            OnDoorPreOpened = function() end,
            OnDoorOpened = function() end,
        },
    }

    -- Fake door setup

    local roomIdx = tonumber(room.Name)
    local door = room:WaitForChild("Door")
    local fakeDoor = Assets.FakeDoor:Clone()
    local shouldBeLocked = room:WaitForChild("Assets", 0.3):WaitForChild("KeyObtain", 0.3) ~= nil

    fakeDoor.Door.MaterialVariant = "PlywoodALT"
    fakeDoor.Sign.MaterialVariant = "Plywood"
    fakeDoor:SetPrimaryPartCFrame(door.PrimaryPart.CFrame)

    local signText = ""
    for _ = #tostring(roomIdx + 1), 3 do
        signText = signText.. "0"
    end

    for _, v in next, fakeDoor.Gui:GetDescendants() do
        if v.ClassName == "TextLabel" then
            v.Text = signText.. tostring(roomIdx + 1)
        end
    end
    
    -- Lock handling

    local connections = {}

    if not shouldBeLocked then
        fakeDoor.Lock:Destroy()

        task.spawn(function()
            while not fakeDoor.GetAttribute(fakeDoor, "IsOpen") do
                if (Root.Position - fakeDoor.PrimaryPart.Position).Magnitude <= 10 then
                    openFakeDoor(doorTable)
                end
    
                task.wait()
            end
        end)
    else
        connections.holdBegan = fakeDoor.Lock.UnlockPrompt.PromptButtonHoldBegan:Connect(function()
            local item = Char:FindFirstChild(config.CustomKeyName) or Char:FindFirstChild("Key") or Char:FindFirstChild("Lockpick")
            
            if item then
                Hum:LoadAnimation(item.Animations.use):Play()
            else
                firesignal(ReSt.Bricks.Caption.OnClientEvent, "You need a key!", true)
            end
        end)

        connections.promptTriggered = fakeDoor.Lock.UnlockPrompt.Triggered:Connect(function()
            local item = Char:FindFirstChild(config.CustomKeyName) or Char:FindFirstChild("Key") or Char:FindFirstChild("Lockpick")
            
            if item then
                for _, v in next, connections do
                    v:Disconnect()
                end
                
                openFakeDoor(doorTable)
                
                if config.DestroyKey ~= false then
                    -- Destroy key

                    item:Destroy()
                end
            end
        end)
    end

    -- Parenting
    
    fakeDoor.Parent = room
    door:Destroy()

    return doorTable
end

-- Scripts

return DoorReplication
