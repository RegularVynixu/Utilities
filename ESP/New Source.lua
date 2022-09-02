-- Services

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local WorldToViewportPoint = Camera.WorldToViewportPoint

local ESP = {
    Containers = {},
    Settings = {
        Distance = true,
        Health = true,
        Tracer = true,
        TracerFrom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 25),
        TracerThickness = 1,
        Outline = true,
        OutlineOpacity = 0.75,
        OutlineOnTop = false,
        Rainbow = false,
        TextSize = 16,
    },
}

-- Misc Functions

local function onCharacterAdded(char)
    Char, Root = char, char:WaitForChild("HumanoidRootPart")
end

local function getPlayerFromRoot(root)
    for _, v in next, Players:GetPlayers() do
        if v.Character and root:IsDescendantOf(v.Character) then
            return v
        end
    end
end

local function getWTVP(vec3)
    local screenPos, onScreen = WorldToViewportPoint(Camera, vec3)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Functions

function ESP:Add(root, options)
    if self.Containers[root] then
        self:Remove(root)
    end

    -- Container
    
    local player = getPlayerFromRoot(root)

    local container = {
        Active = true,
        Root = root,
        Player = player,
        Name = options.Name or player and player.DisplayName or root.Name,
        Color = options.Color or (player and player.Team and player.TeamColor.Color) or Color3.new(1, 1, 1),
        Connections = {},
        Draw = {},
    }

    -- Draw

    local nameLabel = Drawing.new("Text")
    local statsLabel = Drawing.new("Text")
    local tracer = Drawing.new("Line")
    local outline = Instance.new("Highlight")

    nameLabel.Center = true
    nameLabel.Color = container.Color
    nameLabel.Outline = true
    nameLabel.Size = ESP.Settings.TextSize
    nameLabel.Text = container.Name

    statsLabel.Center = true
    statsLabel.Outline = true
    statsLabel.Color = Color3.new(1, 1, 1)
    statsLabel.Size = ESP.Settings.TextSize

    tracer.Color = container.Color
    tracer.From = ESP.Settings.TracerFrom
    tracer.Thickness = ESP.Settings.TracerThickness

    outline.Enabled = false
    outline.FillColor = container.Color
    outline.FillTransparency = 0.75
    outline.OutlineColor = container.Color
    outline.OutlineTransparency = 0
    outline.Parent = options.OutlineFocus or (container.Player and container.Player.Character) or (container.Root.Parent and container.Root.Parent.ClassName == "Model" and container.Root.Parent) or container.Root

    -- Connections

    container.Connections.AncestryChanged = container.Root.AncestryChanged:Connect(function(_, p)
        if not p then
            self:Remove(container.Root)
        end
    end)

    if container.Player and container.Player.Character and container.Player.Character:FindFirstChild("Humanoid") then
        container.Connections.HumanoidDied = container.Player.Character.Humanoid.Died:Connect(function()
            self:Remove(container.Root)
        end)
    end

    -- Indexing

    container.Draw[#container.Draw + 1] = { Type = "Text", Name = "Name", Obj = nameLabel}
    container.Draw[#container.Draw + 1] = { Type = "Text", Name = "Stats", Obj = statsLabel}
    container.Draw[#container.Draw + 1] = { Type = "Line", Name = "Tracer", Obj = tracer}
    container.Draw[#container.Draw + 1] = { Type = "Outline", Name = "Outline", Obj = outline}
    self.Containers[#self.Containers + 1] = container
    
    return container
end

function ESP:Remove(root)
    for i, v in next, self.Containers do
        if v.Root == root then
            for i2, v2 in next, v.Connections do
                v2:Disconnect(); v.Connections[i2] = nil
            end
            
            for i2, v2 in next, v.Draw do
                v2.Obj[v2.Type == "Outline" and "Destroy" or "Remove"](v2.Obj); v.Draw[i2] = nil
            end

            table.remove(self.Containers, i); v = nil
        end
    end
end

-- Scripts

onCharacterAdded(Char)
Plr.CharacterAdded:Connect(onCharacterAdded, char)

RS.Stepped:Connect(function()
    for _, v in next, ESP.Containers do
        local screenPos, onScreen = getWTVP(v.Root.Position)

        if onScreen and v.Active then
            local texts = 0
            for _, v3 in next, v.Draw do
                if v3.Type == "Text" and v3.Obj.Text ~= "" then
                    texts = texts + 1
                end
            end

            for i2, v2 in next, v.Draw do
                local color = ESP.Settings.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or v.Color

                if v2.Type ~= "Outline" then
                    if v2.Type == "Text" then
                        v2.Obj.Size = ESP.Settings.TextSize
                        v2.Obj.Position = screenPos - Vector2.new(0, (texts - i2) * ESP.Settings.TextSize)

                        if v2.Name == "Name" then
                            v2.Obj.Text = v.Name

                        elseif v2.Name == "Stats" then
                            v2.Obj.Text = (ESP.Settings.Distance and "[ ".. (math.floor((v.Root.Position - Root.Position).Magnitude)).. " ]" or "").. (ESP.Settings.Health and v.Player and v.Player.Character and v.Player.Character:FindFirstChild("Humanoid") and " [ ".. (math.floor(100 / v.Player.Character.Humanoid.MaxHealth * v.Player.Character.Humanoid.Health * 10) / 10).. "% ]" or "")
                        end

                    elseif v2.Type == "Line" and ESP.Settings.Tracer then
                        v2.Obj.From = ESP.Settings.TracerFrom
                        v2.Obj.To = screenPos + Vector2.new(0, math.max(texts * ESP.Settings.TextSize / 2, ESP.Settings.TextSize))
                        v2.Obj.Thickness = ESP.Settings.TracerThickness
                    end
                    
                    v2.Obj.Color = color
                    v2.Obj.Visible = v2.Type ~= "Line" or v2.Type == "Line" and ESP.Settings.Tracer
                else
                    if ESP.Settings.Outline then
                        v2.Obj.FillColor = color
                        v2.Obj.FillTransparency = ESP.Settings.OutlineOpacity
                        v2.Obj.OutlineColor = color
                        v2.Obj.DepthMode = Enum.HighlightDepthMode[ESP.Settings.OutlineOnTop and "AlwaysOnTop" or "Occluded"]
                    end
                    
                    v2.Obj.Enabled = ESP.Settings.Outline
                end
            end
        else
            for _, v2 in next, v.Draw do
                if v2.Type ~= "Outline" then
                    v2.Obj.Visible = false
                end
            end
        end
    end
end)

return ESP
