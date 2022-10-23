-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local ReSt = game:GetService("ReplicatedStorage")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

local ModuleScripts = {
    MainGame = require(Plr.PlayerGui.MainUI.Initiator.Main_Game),
    ModuleEvents = require(ReSt.ClientModules.Module_Events),
}

local DefaultConfig = {
    Model = nil,
    Speed = 100,
    DelayTime = 2,
    HeightOffset = Vector3.new(0, 3.5, 0),
    CamShake = {
        true,
        {7.5, 15, 0.1, 1},
        100,
    },
    CanKill = true,
    BreakLights = true,
    FlickerLights = {
        true,
        1,
    },
    Cycles = {
        Min = 1,
        Max = 4,
        WaitTime = 2,
    },
    CustomDialog = {},
}

local Creator = {}

-- Misc Functions

local function drag(objA, objB, speed)
    local reached = false

    local con; con = RS.Stepped:Connect(function(_, step)
        local posA = objA.Position
        local posB = objB.Position
        local diff = Vector3.new(posB.X, 0, posB.Z) - Vector3.new(posA.X, 0, posA.Z)

        if diff.Magnitude > 0.1 then
            objA.CFrame = CFrame.new(posA + diff.Unit * math.min(step * speed, diff.Magnitude - 0.05))
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

    for i, v in next, DefaultConfig do
        if config[i] == nil then
            config[i] = DefaultConfig[i]
        end
    end

    config.Cycles.Max = math.max(config.Cycles.Max, 1)
    config.Cycles.Min = math.clamp(config.Cycles.Min, 1, config.Cycles.Max)
    config.Speed = 50 / 100 * config.Speed

    -- Obtain model

    writefile("customEntity.txt", game:HttpGet(config.Model))
    local model = game:GetObjects((loadcustomasset or getsynasset)("customEntity.txt"))[1]
    delfile("customEntity.txt")

    if model then
        if not model.PrimaryPart then
            model.PrimaryPart = model:FindFirstChildOfClass("Part")
        end

        if model.PrimaryPart then
            return { Model = model, Config = config }
        else
            warn("Failed to find model's PrimaryPart")
        end
    else
        warn("Failed to obtain model")
    end
end

Creator.runEntity = function(entity)
    assert(typeof(entity) == "table")
    
    if entity.Model and entity.Model.PrimaryPart then
        -- Obtain nodes

        local nodes = {}

        for _, room in next, workspace.CurrentRooms:GetChildren() do
            if room:FindFirstChild("Nodes") then
                for _, node in next, room.Nodes:GetChildren() do
                    nodes[#nodes + 1] = node
                end
            end
        end

        -- Set up kill connection

        local movementCon = nil

        movementCon = RS.Stepped:Connect(function()
            if entity.Config.CanKill and not Char:GetAttribute("Hiding") then
                local posA = entity.Model.PrimaryPart.Position
                local posB = Root.Position
                local found = workspace:FindPartOnRayWithIgnoreList(Ray.new(posA, (posB - posA).Unit * 100), { entity.Model })

                if found and found:IsDescendantOf(Char) then
                    movementCon:Disconnect()
                    Hum.Health = 0

                    if #entity.Config.CustomDialog > 0 then
                        debug.setupvalue(getconnections(ReSt.Bricks.DeathHint.OnClientEvent)[1].Function, 1, entity.Config.CustomDialog)
                    end
                end
            end
            
            local camShake = entity.Config.CamShake
            local mag = (Root.Position - entity.Model.PrimaryPart.Position).Magnitude

            if camShake[1] and mag <= camShake[3] then
                camShake[2][1] = DefaultConfig.CamShake[2][1] / camShake[3] * (camShake[3] - math.min(mag, camShake[3]))
                
                ModuleScripts.MainGame.camShaker:ShakeOnce(table.unpack(camShake[2]))
            end
        end)

        -- Pre-cycle setup
        
        entity.Model.PrimaryPart.CFrame = nodes[1].CFrame + entity.Config.HeightOffset
        entity.Model.Parent = workspace

        if entity.Config.FlickerLights[1] then
            task.spawn(ModuleScripts.ModuleEvents.flickerLights, workspace.CurrentRooms[Plr:GetAttribute("CurrentRoom")], entity.Config.FlickerLights[2])
        end

        task.wait(entity.Config.DelayTime or 0)

        -- Go through cycles

        local cycles = entity.Config.Cycles

        for _ = 1, math.random(cycles.Min, cycles.Max) do
            for i = 1, #nodes, 1 do
                if entity.Config.BreakLights then
                    ModuleScripts.ModuleEvents.breakLights(nodes[i].Parent.Parent)
                end

                drag(entity.Model.PrimaryPart, nodes[i], entity.Config.Speed)
            end

            if cycles.Max > 1 then
                for i = #nodes, 1, -1 do
                    drag(entity.Model.PrimaryPart, nodes[i], entity.Config.Speed)
                end
            end

            task.wait(cycles.WaitTime or 0)
        end

        -- Remove entity after cycles

        if movementCon then
            movementCon:Disconnect()
        end

        entity.Model:Destroy()
    else
        warn("Failure - Model does not have a PrimaryPart")
    end
end

-- Scripts

return Creator
