-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local ESP = {
    enabled = true,
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

local function objectIsPlayer(obj)
    return obj:IsDescendantOf(Players)
end

function ESP:Add(obj, settings)
    local container = ESP.containers[root] 
    if container then
        Remove(container.root)
    end

    container = {
        connections = {},
        draw = {},
        object = obj,
        root = settings.root or obj,
        active = true,
    }

    -- Construction

    local nameLabel = Drawing.new("Text")
    local displayLabel = Drawing.new("Text")
    local tracer = Drawing.new("Line")

    -- Setup

    local color = settings.color or (objectIsPlayer(obj) and obj.Team and obj.TeamColor.Color) or Color3.fromRGB(255, 255, 255)

    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Color = color
    nameLabel.Text = settings.name or obj.Name
    nameLabel.Position = getWTVP(container.root.Position)
    nameLabel.Size = ESP.settings.textSize

    displayLabel.Center = true
    displayLabel.Outline = true
    displayLabel.Color = Color3.new(1, 1, 1)
    displayLabel.Position = getWTVP(container.root.Position)
    displayLabel.Size = ESP.settings.textSize

    tracer.Color = nameLabel.Color
    tracer.From = ESP.settings.tracerFrom
    tracer.Thickness = ESP.settings.tracerThickness

    -- Indexing

    container.draw.name = {
        obj = nameLabel,
        type = "Text",
        offset = Vector2.new(0, -ESP.settings.textSize),
    }
    container.draw.display = {
        obj = displayLabel,
        type = "Text",
    }
    container.draw.tracer = {
        obj = tracer,
        type = "Tracer",
        offset = Vector2.new(0, ESP.settings.textSize),
    }
    ESP.containers[container.root] = container

    -- Scripts

    container.connections.ancestryChanged = container.root.AncestryChanged:Connect(function(_, p)
        if not p then
            ESP:Remove(container.root)
        end
    end)

    return container
end

function ESP:Remove(root)
    local container = ESP.containers[root] 
    if container then
        container.active = false

        for i, v in next, container.connections do
            v:Disconnect()
            container.connections[i] = nil
        end
        for i, v in next, container.draw do
            v.obj:Remove()
            container.draw[i] = nil
        end

        ESP.containers[root] = nil
    end
end

function ESP:UpdateContainers()
    for i, v in next, ESP.containers do
        local rootPos, visible = getWTVP(v.root.Position)
        v.active = visible

        if v.active then
            for i2, v2 in next, v.draw do
                if not v2.obj.Visible then
                    v2.obj.Visible = true
                end
                
                if v2.type == "Text" then
                    v2.obj.Size = ESP.settings.textSize
                    v2.obj.Position = rootPos + (v2.offset or Vector2.new())

                elseif v2.type == "Tracer" then
                    v2.obj.From = ESP.settings.tracerFrom
                    v2.obj.To = rootPos + (v2.offset or Vector2.new())
                    v2.obj.Thickness = ESP.settings.tracerThickness
                end
            end

            -- Updating display

            v.draw.display.obj.Text = (ESP.settings.distance and "[".. math.floor(GetMag(Root.Position, v.root.Position)).. " studs away]" or "")

            if v.object and objectIsPlayer(v.object) then
                local humanoid = v.object.Character:WaitForChild("Humanoid")
                if humanoid then
                    local healthPercentage = 100 / humanoid.MaxHealth * humanoid.Health
                    v.draw.display.obj.Text = v.draw.display.obj.Text.. (ESP.settings.health and (#v.draw.display.obj.Text == 0 and "" or " ").. "[".. healthPercentage.. "%]" or "")
                end
            end
        else
            for i2, v2 in next, v.draw do
                if v2.obj.Visible then
                    v2.obj.Visible = false
                end
            end
        end
    end
end

-- Scripts

RS.RenderStepped:Connect(ESP.UpdateContainers)

Plr.CharacterAdded:Connect(function(c)
    Char, Root = c, c:WaitForChild("HumanoidRootPart")
end)

return ESP
