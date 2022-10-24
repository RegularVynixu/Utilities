-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
local StaticRushSpeed = 50

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    ModuleEvents = require(ReSt.ClientModules.Module_Events),
}
local DefaultConfig = {
    Speed = 100,
    DelayTime = 2,
    HeightOffset = 0,
    CanKill = true,
    BreakLights = true,
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
    CustomDialog = {},
}
local Creator = {}

-- Misc Functions

local function drag(model, objB, speed)
    local reached = false

    local con; con = RS.Stepped:Connect(function(_, step)
        local posA = model.PrimaryPart.Position
        local posB = objB.Position
        local diff = Vector3.new(posB.X, 0, posB.Z) - Vector3.new(posA.X, 0, posA.Z)

        if diff.Magnitude > 0.1 then
            model:SetPrimaryPartCFrame(CFrame.new(posA + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05)))
        else
            reached = true
        end
    end)

    repeat task.wait() until reached
    
    con:Disconnect()
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

    local entityModel = nil

    if tonumber(config.Model) or string.find(config.Model, "rbxassetid") then
        local assetId = string.gsub(config.Model, "%D", "")

        entityModel = game:GetObjects("rbxassetid://".. assetId)[1]
    else
        writefile("customEntity.txt", game:HttpGet(config.Model))

        entityModel = game:GetObjects((getcustomasset or getsynasset)("customEntity.txt"))[1]

        delfile("customEntity.txt")
    end

    if entityModel then
        local pPart = entityModel.PrimaryPart or entityModel:FindFirstChildOfClass("Part")

        if pPart then
            entityModel.PrimaryPart = pPart
            pPart.Anchored = true

            for _, v in next, entityModel:GetDescendants() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            
            return { Model = entityModel, Config = config }
        else
            warn("Failure - Could not obtain model's PrimaryPart")
        end
    else
        warn("Failure - Could not obtain entity model")
    end
end

Creator.runEntity = function(entity)
    assert(typeof(entity) == "table")
    assert(entity.Model and entity.Model.PrimaryPart and entity.Config)

    -- Obtain nodes

    local nodes = {}

    for _, room in next, workspace.CurrentRooms:GetChildren() do
        if room:FindFirstChild("Nodes") then
            for _, node in next, room.Nodes:GetChildren() do
                nodes[#nodes + 1] = node
            end
        end
    end

    -- Death & Camera shaking

    local movementCon = nil

    movementCon = RS.Stepped:Connect(function()
        if entity.Config.CanKill and not Char:GetAttribute("Hiding") then
            local posA = entity.Model.PrimaryPart.Position
            local posB = Root.Position
            local found = FindPartOnRayWithIgnoreList(workspace, Ray.new(posA, (posB - posA).Unit * 100), { entity.Model })

            if found and found.IsDescendantOf(found, Char) then
                movementCon:Disconnect()
                Hum.Health = 0

                if #entity.Config.CustomDialog > 0 then
                    ReSt.GameStats["Player_".. Plr.Name].Total.DeathCause.Value = entity.Model.Name
                    debug.setupvalue(getconnections(ReSt.Bricks.DeathHint.OnClientEvent)[1].Function, 1, entity.Config.CustomDialog)
                end
            end
        end
        
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
    end)

    -- Pre-cycle setup

    local firstRoom = workspace.CurrentRooms:GetChildren()[1]

    entity.Model:SetPrimaryPartCFrame( (firstRoom:FindFirstChild("RoomStart") and firstRoom.RoomStart.CFrame or nodes[1].CFrame + Vector3.new(0, 3.5, 0)) + Vector3.new(0, entity.Config.HeightOffset, 0) )
    entity.Model.Parent = workspace

    if entity.Config.FlickerLights[1] then
        task.spawn(ModuleScripts.ModuleEvents.flickerLights, workspace.CurrentRooms[game:GetService("ReplicatedStorage").GameData.LatestRoom.Value], entity.Config.FlickerLights[2])
    end

    task.wait(entity.Config.DelayTime or 0)

    -- Go through cycles

    local cycles = entity.Config.Cycles

    for _ = 1, math.random(cycles.Min, cycles.Max) do
        for i = 1, #nodes, 1 do
            if entity.Config.BreakLights then
                ModuleScripts.ModuleEvents.breakLights(nodes[i].Parent.Parent)
            end

            drag(entity.Model, nodes[i], entity.Config.Speed)
        end

        if cycles.Max > 1 then
            for i = #nodes, 1, -1 do
                drag(entity.Model, nodes[i], entity.Config.Speed)
            end
        end

        task.wait(cycles.WaitTime or 0)
    end

    -- Remove entity after cycles

    if movementCon then
        movementCon:Disconnect()
    end

    entity.Model:Destroy()
end

-- Scripts

return Creator
