-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local ESP = {
    connections = {},
    containers = {},
    settings = {
        distance = true,
        health = true,
        tracers = true,
        rainbow = false,
        textSize = 16,
        tracerFrom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 25),
        tracerThickness = 1,
    },
}

-- Functions

local function getWTVP(vec3)
    local wtvp, visible = Camera:WorldToViewportPoint(vec3)
    return Vector2.new(wtvp.X, wtvp.Y), visible
end

local function GetMag(a, b)
    return (Vector3.new(b.X, b.Y, b.Z) - Vector3.new(a.X, a.Y, a.Z)).Magnitude
end

local function objectIsPlayer(object)
    return object:IsDescendantOf(Players)
end

function ESP:Add(object, settings)
    if ESP.containers[object] then
        ESP:Remove(object)
    end

    local container = {
        connections = {},
        draw = {},
        object = object,
        root = settings.root or object,
        active = true,
    }

    -- Construction

    local displayLabel = Drawing.new("Text")
    local tracer = Drawing.new("Line")

    local color = settings.color or (objectIsPlayer(object) and object.Team) and object.TeamColor.Color or Color3.fromRGB(255, 255, 255)

    displayLabel.Center = true
    displayLabel.Outline = true
    displayLabel.Color = color
    displayLabel.Position = getWTVP(container.root.Position)
    displayLabel.Size = ESP.settings.textSize

    tracer.Color = color
    tracer.From = ESP.settings.tracerFrom
    tracer.Thickness = ESP.settings.tracerThickness

    -- Indexing

    container.draw.display = {
        object = displayLabel,
        type = "Text",
        canRGB = true,
        originalColor = color,
    }
    container.draw.tracer = {
        object = tracer,
        type = "Tracer",
        offset = Vector2.new(0, ESP.settings.textSize),
        canRGB = true,
        originalColor = color,
    }

    ESP.containers[container.object] = container

    -- Scripts

    container.connections.ancestryChanged = container.root.AncestryChanged:Connect(function(_, p)
        if not p then
            ESP:Remove(container.root)
        end
    end)

    return container
end

function ESP:Remove(object)
    local container = ESP.containers[object] 
    if container then
        container.active = false

        for i, v in next, container.connections do
            v:Disconnect()
            container.connections[i] = nil
        end
        for i, v in next, container.draw do
            v.object:Remove()
            container.draw[i] = nil
        end

        ESP.containers[object] = nil
    end
end

function ESP:UpdateContainers()
    for i, v in next, ESP.containers do
        local rootPos, visible = getWTVP(v.root.Position)
        v.active = visible

        if v.active then
            for i2, v2 in next, v.draw do
                if not v2.object.Visible then
                    v2.object.Visible = true
                end
                
                if v2.type == "Text" then
                    v2.object.Size = ESP.settings.textSize
                    v2.object.Position = rootPos + (v2.offset or Vector2.new())

                elseif v2.type == "Tracer" then
                    if ESP.settings.tracers then
                        v2.object.From = ESP.settings.tracerFrom
                        v2.object.To = rootPos + (v2.offset or Vector2.new())
                        v2.object.Thickness = ESP.settings.tracerThickness
                    else
                        v2.object.Visible = false
                    end
                end
            end

            -- Update draws

            v.draw.display.object.Text = v.object.Name

            if ESP.settings.distance then
                v.draw.display.object.Text = v.draw.display.object.Text.. " [".. math.floor(GetMag(Root.Position, v.root.Position)).. " distance]"
            end

            if objectIsPlayer(v.object) and ESP.settings.health then
                local humanoid = v.object.Character:WaitForChild("Humanoid")
                if humanoid then
                    local healthPercentage = math.floor(100 / humanoid.MaxHealth * humanoid.Health * 10) / 10
                    v.draw.display.object.Text = v.draw.display.object.Text.. " [".. healthPercentage.. "%]"
                end
            end

            -- Rainbow

            for i2, v2 in next, v.draw do
                if v2.canRGB then
                    v2.object.Color = ESP.settings.rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or v2.originalColor
                end
            end
        else
            for i2, v2 in next, v.draw do
                if v2.object.Visible then
                    v2.object.Visible = false
                end
            end
        end
    end
end

-- Scripts

ESP.connections.updateContainers = RS.RenderStepped:Connect(ESP.UpdateContainers)
ESP.connections.playerRemoving = Players.PlayerRemoving:Connect(function(p)
    for i, v in next, ESP.containers do
        if v.object == p then
            ESP:Remove(v.root)
        end
    end
end)
ESP.connections.characterAdded = Plr.CharacterAdded:Connect(function(c)
    Char, Root = c, c:WaitForChild("HumanoidRootPart")
end)

return ESP
