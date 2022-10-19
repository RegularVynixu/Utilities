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
        DisplayNames = true,
        Distance = true,
        Health = true,
        Tracer = true,
        TracerFrom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 25),
        TracerThickness = 1,
        Outline = true,
        OutlineOpacity = 0.75,
        OutlineOnTop = true,
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

local function isAlive(root)
    if not root.Parent then
        return false
    elseif root.Parent:FindFirstChild("Humanoid") and root.Parent.Humanoid.Health <= 0 then
        return false
    end

    return true
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
        Name = options.Name or (player and player[self.Settings.DisplayNames and "DisplayName" or "Name"]) or root.Name,
        Color = options.Color or (player and player.Team and player.TeamColor.Color) or Color3.new(1, 1, 1),
        OutlineFocus = options.OutlineFocus or (player and player.Character) or (root.Parent and root.Parent.ClassName == "Model" and root.Parent) or root,
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
    nameLabel.Size = self.Settings.TextSize
    nameLabel.Text = container.Name

    statsLabel.Center = true
    statsLabel.Outline = true
    statsLabel.Color = Color3.new(1, 1, 1)
    statsLabel.Size = self.Settings.TextSize

    tracer.Color = container.Color
    tracer.From = self.Settings.TracerFrom
    tracer.Thickness = self.Settings.TracerThickness

    outline.Enabled = false
    outline.FillColor = container.Color
    outline.FillTransparency = 0.75
    outline.OutlineColor = container.Color
    outline.OutlineTransparency = 0
    outline.Parent = container.OutlineFocus

    -- Connections

    if player then
        container.Connections.changeTeam = player:GetPropertyChangedSignal("Team"):Connect(function()
            self:Remove(container.Root)
        end)
    end

    -- Indexing

    container.Draw[#container.Draw + 1] = { Type = "Text", Name = "Name", Obj = nameLabel }
    container.Draw[#container.Draw + 1] = { Type = "Text", Name = "Stats", Obj = statsLabel }
    container.Draw[#container.Draw + 1] = { Type = "Line", Name = "Tracer", Obj = tracer }
    container.Draw[#container.Draw + 1] = { Type = "Outline", Name = "Outline", Obj = outline }
    self.Containers[root] = container
    
    return container
end

function ESP:Remove(root)
    local container = self.Containers[root]

    if container then
        container.Active = false
        
        for _, v in next, container.Connections do
            v:Disconnect(); v = nil
        end
        
        for _, v in next, container.Draw do
            v.Obj[v.Type == "Outline" and "Destroy" or "Remove"](v.Obj); v = nil
        end

        self.Containers[root] = nil
    end
end

-- Scripts

onCharacterAdded(Char)
Plr.CharacterAdded:Connect(onCharacterAdded, char)

RS.Stepped:Connect(function()
    for root, container in next, ESP.Containers do
        if isAlive(root) then
            local screenPos, onScreen = getWTVP(root.Position)

            if onScreen and container.Active then
                local texts = 0
                for _, v in next, container.Draw do
                    if v.Type == "Text" and v.Obj.Text ~= "" then
                        texts += 1
                    end
                end
    
                for i, v in next, container.Draw do
                    local color = ESP.Settings.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or container.Color

                    if v.Type ~= "Outline" then
                        if v.Type == "Text" then
                            v.Obj.Size = ESP.Settings.TextSize
                            v.Obj.Position = screenPos - Vector2.new(0, (texts - i) * ESP.Settings.TextSize)
    
                            if v.Name == "Name" then
                                v.Obj.Text = container.Name
    
                            elseif v.Name == "Stats" then
                                local dist = ESP.Settings.Distance and "[ ".. (math.floor((root.Position - Root.Position).Magnitude)).. " ]" or ""
                                local health = ESP.Settings.Health and root.Parent:FindFirstChild("Humanoid") and " [ ".. (math.floor(100 / root.Parent.Humanoid.MaxHealth * root.Parent.Humanoid.Health * 10) / 10).. "% ]" or ""

                                v.Obj.Text = dist.. health
                            end
    
                        elseif v.Type == "Line" and ESP.Settings.Tracer then
                            v.Obj.From = ESP.Settings.TracerFrom
                            v.Obj.To = screenPos + Vector2.new(0, math.max(texts * ESP.Settings.TextSize / 2, ESP.Settings.TextSize))
                            v.Obj.Thickness = ESP.Settings.TracerThickness
                        end
                        
                        v.Obj.Color = color
                        v.Obj.Visible = v.Type ~= "Line" or v.Type == "Line" and ESP.Settings.Tracer
                    else
                        if ESP.Settings.Outline then
                            v.Obj.FillColor = color
                            v.Obj.FillTransparency = ESP.Settings.OutlineOpacity
                            v.Obj.OutlineColor = color
                            v.Obj.DepthMode = Enum.HighlightDepthMode[ESP.Settings.OutlineOnTop and "AlwaysOnTop" or "Occluded"]
                        end
                        
                        v.Obj.Enabled = ESP.Settings.Outline

                        -- Refresh outline visibility

                        v.Obj.Parent = game
                        v.Obj.Parent = container.OutlineFocus
                    end
                end
            else
                for _, v in next, container.Draw do
                    if v.Type ~= "Outline" then
                        v.Obj.Visible = false
                    end
                end
            end
        else
            ESP:Remove(root)
        end
    end
end)

return ESP
