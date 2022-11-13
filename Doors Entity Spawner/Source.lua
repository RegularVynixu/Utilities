-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")
local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

local FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
local WorldToViewportPoint = Camera.WorldToViewportPoint
local StaticRushSpeed = 50
local MinTeaseSize = 150
local MaxTeaseSize = 300

local SelfModules = {
    Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
}
local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    ModuleEvents = require(ReSt.ClientModules.Module_Events),
}
local DefaultConfig = {
    Speed = 100,
    DelayTime = 2,
    HeightOffset = 0,
    CanKill = true,
    KillRange = 50,
    BreakLights = true,
    BackwardsMovement = false,
    FlickerLights = {
        true,
        1,
    },
    Cycles = {
        Min = 1,
        Max = 1,
        WaitTime = 2,
    },
    CamShake = {
        true,
        {5, 15, 0.1, 1},
        100,
    },
    Jumpscare = {
        false,
        {},
    },
    CustomDialog = {},
}
local Connections = {}
local StoredSounds = {}

local Creator = {}

-- Misc Functions

local function drag(model, dest, speed)
    if Connections[model].Drag then
        Connections[model].Drag:Disconnect()
    end

    local reached = false
    
    Connections[model].Drag = RS.Stepped:Connect(function(_, step)
        if model.Parent then
            local rootPos = model.PrimaryPart.Position
            local diff = Vector3.new(dest.X, dest.Y, dest.Z) - rootPos
    
            if diff.Magnitude > 0.1 then
                model:SetPrimaryPartCFrame(CFrame.new(rootPos + diff.Unit * math.min(step * speed, diff.Magnitude)))
            else
                Connections[model].Drag:Disconnect()
    
                reached = true
            end
        else
            Connections[model].Drag:Disconnect()
        end
    end)

    repeat task.wait() until reached
end

local function playSound(soundId, properties)
    for i, v in next, StoredSounds do
        v:Destroy()
        StoredSounds[i] = nil
    end

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://".. ({string.gsub(soundId, "%D", "")})[1]
    sound.Playing = true
    sound.Parent = workspace

    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Playing" and i ~= "Parent" then
            sound[i] = v
        end
    end

    StoredSounds[#StoredSounds + 1] = sound

    return sound
end

local function destroy(entityTable)
    for _, v in next, Connections[entityTable.Model] do
        v:Disconnect()
    end

    Connections[entityTable.Model] = nil
    entityTable.Model:Destroy()
    entityTable.Debug.OnEntityDespawned(entityTable)
end

-- Functions

Creator.createEntity = function(config)
    -- Prepare configs

    assert(typeof(config) == "table")
    assert(config.Model)

    for i, v in next, DefaultConfig do
        if config[i] == nil then
            config[i] = DefaultConfig[i]
        end
    end
    
    config.Speed = StaticRushSpeed / 100 * config.Speed

    -- Obtain custom model

    local entityModel = LoadCustomInstance(config.Model)

    if typeof(entityModel) == "Instance" and entityModel.ClassName == "Model" then
        local pPart = entityModel.PrimaryPart or entityModel:FindFirstChildWhichIsA("BasePart")

        if pPart then
            entityModel.PrimaryPart = pPart
            pPart.Anchored = true
            entityModel:SetAttribute("IsCustomEntity", true)

            if config.CustomName then
                entityModel.Name = config.CustomName
            end

            for _, v in next, entityModel:GetDescendants() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end

            -- Setup Connections

            Connections[entityModel] = {}

            -- Return
            
            return {
                Model = entityModel,
                Config = config,
                Debug = {
                    OnEntitySpawned = function() end,
                    OnEntityDespawned = function() end,
                    OnEntityStartMoving = function() end,
                    OnEntityFinishedRebound = function() end,
                    OnEntityEnteredRoom = function() end,
                    OnLookAtEntity = function() end,
                    OnDeath = function() end,
                },
            }
        else
            warn("Failure - Could not find model's PrimaryPart")
        end
    else
        warn("Failure - Could not obtain model")
    end
end

Creator.runEntity = function(entity)
    -- Obtain nodes

    local nodes = {}

    for _, room in next, workspace.CurrentRooms:GetChildren() do
        if room:FindFirstChild("Nodes") then
            local roomNodes = room.Nodes:GetChildren()

            table.sort(roomNodes, function(a, b)
                return a.Name < b.Name
            end)

            for _, node in next, roomNodes do
                nodes[#nodes + 1] = node
            end
        end
    end

    -- Pre-cycle setup

    local firstRoom = workspace.CurrentRooms:GetChildren()[1]
    entity.Model.Parent = workspace

    if entity.Config.FlickerLights[1] then
        task.spawn(ModuleScripts.ModuleEvents.flickerLights, workspace.CurrentRooms[ReSt.GameData.LatestRoom.Value], entity.Config.FlickerLights[2])
    end

    entity.Debug.OnEntitySpawned(entity)
    task.wait(entity.Config.DelayTime or 0)

    -- Movement

    local enteredRooms = {}

    Connections[entity.Model].Movement = RS.Stepped:Connect(function()
        if entity.Model.Parent and Hum.Health > 0 then
            local entityPos = entity.Model.PrimaryPart.Position
            local rootPos = Root.Position
            local found = FindPartOnRayWithIgnoreList(workspace, Ray.new(entityPos, rootPos - entityPos), {entity.Model, Char})
    
            local groundRay = Ray.new(entityPos, Vector3.new(0, -4.5 - entity.Config.HeightOffset))
            local groundFound = FindPartOnRayWithIgnoreList(workspace, groundRay, {entity.Model, Char})

            if groundFound and (groundFound.Name == "Floor" or string.find(groundFound.Name, "Carpet")) then
                for _, room in next, workspace.CurrentRooms:GetChildren() do
                    if groundFound.IsDescendantOf(groundFound, room) and not table.find(enteredRooms, room) then
                        enteredRooms[#enteredRooms + 1] = room

                        entity.Debug.OnEntityEnteredRoom(entity, room)
                    end
                end
            end

            if not found then
                -- LookAt

                local _, onScreen = WorldToViewportPoint(Camera, entityPos)

                if onScreen then
                    entity.Debug.OnLookAtEntity(entity)
                end

                -- Within kill range

                if (Root.Position - entity.Model.PrimaryPart.Position).Magnitude <= entity.Config.KillRange then
                    -- Entity deflection
                    
                    local doggo = workspace:FindFirstChild("Doggo")
                    local crucifix = Char:FindFirstChild("Crucifix")
                    
                    if doggo or crucifix then
                        if doggo then
                            doggo.Growl:Play()
                        end
                        
                        Connections[entity.Model].Movement:Disconnect()
                        entity.Model:SetAttribute("StopMovement", true)

                        -- Repent

                        local nodeIdx, nearest = nil, math.huge

                        for i, v in next, nodes do
                            local dist = (v.Position - entityPos).Magnitude

                            if dist < nearest then
                                nodeIdx, nearest = i, dist
                            end
                        end

                        for i = nodeIdx, 1, -1 do
                            drag(entity.Model, nodes[i].Position + Vector3.new(0, 3.5 + entity.Config.HeightOffset, 0), entity.Config.Speed)
                        end

                        destroy(entity)

                        return
                    end

                    -- Killing
        
                    if entity.Config.CanKill and not Char.GetAttribute(Char, "Hiding") then
                        Connections[entity.Model].Movement:Disconnect()
        
                        -- Jumpscare
        
                        if entity.Config.Jumpscare[1] then
                            Creator.runJumpscare(entity.Config.Jumpscare[2])
                        end
        
                        -- Death handling + custom dialog
                        
                        Hum.Health = 0
                        entity.Debug.OnDeath(entity)
        
                        if #entity.Config.CustomDialog > 0 then
                            ReSt.GameStats["Player_".. Plr.Name].Total.DeathCause.Value = entity.Model.Name
        
                            debug.setupvalue(getconnections(ReSt.Bricks.DeathHint.OnClientEvent)[1].Function, 1, entity.Config.CustomDialog)
                        end
                    end
                end
            end

            -- Cam shake
    
            if Root and entity.Model.PrimaryPart then
                local camShake = entity.Config.CamShake
                local mag = (Root.Position - entity.Model.PrimaryPart.Position).Magnitude
    
                if camShake[1] and mag <= camShake[3] then
                    local shakeRep = {}
    
                    for i, v in next, camShake[2] do
                        shakeRep[i] = v
                    end
                    shakeRep[1] = camShake[2][1] / camShake[3] * (camShake[3] - mag)
                    
                    ModuleScripts.MainGame.camShaker.ShakeOnce(ModuleScripts.MainGame.camShaker, table.unpack(shakeRep))
                    shakeRep = nil
                end
            end
        else
            Connections[entity.Model].Movement:Disconnect()
        end
    end)

    entity.Debug.OnEntityStartMoving(entity)

    -- Go through cycles

    if entity.Config.BackwardsMovement then
        local inverseNodes = {}

        for i = #nodes, 1, -1 do
            inverseNodes[#inverseNodes + 1] = nodes[i]
        end

        nodes = inverseNodes
    end

    local cycles = entity.Config.Cycles
    local nodeHeightOffset = 3.5 + entity.Config.HeightOffset

    entity.Model:SetPrimaryPartCFrame(nodes[1].CFrame + Vector3.new(0, 3.5 + entity.Config.HeightOffset, 0))

    for cycle = 1, math.random(cycles.Min, cycles.Max) do
        for i = 1, #nodes, 1 do
            if not entity.Model:GetAttribute("StopMovement") then
                if entity.Config.BreakLights then
                    ModuleScripts.ModuleEvents.breakLights(nodes[i].Parent.Parent)
                end
    
                drag(entity.Model, nodes[i].Position + Vector3.new(0, nodeHeightOffset, 0), entity.Config.Speed)
            end
        end

        if cycles.Max > 1 then
            for i = #nodes, 1, -1 do
                if not entity.Model:GetAttribute("StopMovement") then
                    drag(entity.Model, nodes[i].Position + Vector3.new(0, nodeHeightOffset, 0), entity.Config.Speed)
                end
            end
        end
        
        entity.Debug.OnEntityFinishedRebound(entity)

        task.wait(cycles.WaitTime or 0)
    end

    -- Remove entity after cycles

    destroy(entity)
end

Creator.runJumpscare = function(config)
    -- Pre-setup

    local image1 = LoadCustomAsset(config.Image1)
    local image2 = LoadCustomAsset(config.Image2)
    local sound1, sound2 = nil, nil

    Char:SetPrimaryPartCFrame(CFrame.new(0, 9e9, 0))

    -- UI Construction

    local JumpscareGui = Instance.new("ScreenGui")
    local Background = Instance.new("Frame")
    local Face = Instance.new("ImageLabel")

    JumpscareGui.Name = "JumpscareGui"
    JumpscareGui.IgnoreGuiInset = true
    JumpscareGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Background.Name = "Background"
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 999

    Face.Name = "Face"
    Face.AnchorPoint = Vector2.new(0.5, 0.5)
    Face.BackgroundTransparency = 1
    Face.Position = UDim2.new(0.5, 0, 0.5, 0)
    Face.ResampleMode = Enum.ResamplerMode.Pixelated
    Face.Size = UDim2.new(0, 150, 0, 150)
    Face.Image = image1

    Face.Parent = Background
    Background.Parent = JumpscareGui
    JumpscareGui.Parent = CG

    -- Tease

    if config.Tease[1] then
        if typeof(config.Sound1) == "table" then
            sound1 = playSound(config.Sound1[1], config.Sound1[2])
        end

        local rdmTease = math.random(config.Tease.Min, config.Tease.Max)

        for _ = config.Tease.Min, rdmTease do
            task.wait(math.random(100, 200) / 100)

            local growFactor = (MaxTeaseSize - MinTeaseSize) / rdmTease
            Face.Size = UDim2.new(0, Face.AbsoluteSize.X + growFactor, 0, Face.AbsoluteSize.Y + growFactor)
        end
        
        task.wait(math.random(100, 200) / 100)
    end

    -- Scare

    if config.Flashing[1] then
        task.spawn(function()
            while JumpscareGui.Parent do
                Background.BackgroundColor3 = config.Flashing[2]
                task.wait(math.random(25, 100) / 1000)
                Background.BackgroundColor3 = Color3.new(0, 0, 0)
                task.wait(math.random(25, 100) / 1000)
            end
        end)
    end

    if config.Shake then
        task.spawn(function()
            local origin = Face.Position

            while JumpscareGui.Parent do
                Face.Position = origin + UDim2.new(0, math.random(-10, 10), 0, math.random(-10, 10))
                Face.Rotation = math.random(-5, 5)

                task.wait()
            end
        end)
    end

    if typeof(config.Sound2) == "table" then
        sound2 = playSound(config.Sound2[1], config.Sound2[2])
    end

    Face.Image = image2
    Face.Size = UDim2.new(0, 750, 0, 750)

    TS:Create(Face, TweenInfo.new(0.75), { Size = UDim2.new(0, 2000, 0, 2000), ImageTransparency = 0.5 }):Play()
    task.wait(0.75)
    JumpscareGui:Destroy()

    if sound1 then
        sound1:Stop()
    end

    if sound2 then
        sound2:Stop()
    end
end

-- Scripts

return Creator
