if Vynixu_ESPModule then return Vynixu_ESPModule end -- silly goose

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local localPlayer = Players.LocalPlayer
local localChar = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localRoot = localChar:WaitForChild("HumanoidRootPart")
local localCamera = workspace.CurrentCamera

local vec2new = Vector2.new
local col3new = Color3.new
local col3hsv = Color3.fromHSV
local drawnew = Drawing.new
local instnew = Instance.new
local waitForChild = game.WaitForChild
local findFirstIsA = game.FindFirstChildWhichIsA
local descendantOf = game.IsDescendantOf
local getPlayers = Players.GetPlayers
local wtvp = localCamera.WorldToViewportPoint
local math_max = math.max
local math_round = math.round
local math_clamp = math.clamp
local table_insert = table.insert
local string_lower = string.lower

local module = {
    Containers = {},
    Connections = {},
    Config = {
        Rainbow = false,
        TextSize = 16,
        Distance = {
            Enabled = true,
            Max = math.huge
        },
        Health = {
            Enabled = true,
            Type = "Percentage" -- "Fraction"
        },
        Tracer = {
            Enabled = true,
            Thickness = 1,
            Color = col3new(1, 1, 1),
            From = vec2new(localCamera.ViewportSize.X / 2, localCamera.ViewportSize.Y)
        },
        Highlight = {
            Enabled = true,
            AlwaysOnTop = true,
            Color = col3new(1, 1, 1),
            Transparency = {
                Fill = 0.75,
                Outline = 0.75
            }
        }
    }
}

-- Functions
local function onCharacterAdded(char)
    localChar, localRoot = char, waitForChild(char, "HumanoidRootPart")
end

local function isAlive(container)
    local rootPart = container.Root
    local humanoid = container.Humanoid
    if not rootPart or not rootPart.Parent then
        return false
    elseif humanoid and humanoid.Health <= 0 then
        return false
    end
    return true
end

local function checkCallback(container, key)
    local callback = container.Callbacks[key]
    if not callback then
        warn("Failed to find callback: " .. key)
        return false
    end
    return true, {callback()}
end

function module:Add(rootPart, options, callbacks)
    if typeof(rootPart) == "Instance" and rootPart.ClassName == "Model" then
        rootPart = rootPart.PrimaryPart or findFirstIsA(rootPart, "BasePart")
    end
    if not rootPart then
        warn("Failed to find root part.")
        return
    elseif self.Containers[rootPart] then
        self:Remove(rootPart)
    end

    -- Setup callbacks (nullable)
    callbacks = (typeof(callbacks) == "table") and callbacks or {}

    -- Get player from rootPart (nullable)
    local player;
    for _, plr in getPlayers(Players) do
        if plr.Character and descendantOf(plr.Character, rootPart) then
            player = plr
            break
        end
    end

    -- Get player team color (nullable)
    local teamColor;
    if player then
        teamColor = player.TeamColor.Color
    end

    -- Construct container
    local config = {
        Name = options.Name or rootPart.Name,
        Color = options.Color or teamColor or col3new(1, 1, 1),
        HighlightFocus = options.HighlightFocus or rootPart,
        Hidden = false
    }
    local connections = {}
    local drawing = {}
    local container = {
        Root = rootPart,
        Connections = connections,
        Drawing = drawing,
        Callbacks = callbacks,
        Config = config,
        Toggle = function(self, bool)
            if self.Config.Hidden ~= bool then
                self.Config.Hidden = bool
                for _, draw in self.Drawing do
                    if draw.Type ~= "Highlight" then
                        draw.Obj.Visible = bool
                    else
                        draw.Obj.Enabled = bool
                    end
                end
            end
        end,
        Remove = function(self)
            module:Remove(self.Root)
        end
    }

    -- Connections
    connections.AncestryChanged = rootPart.AncestryChanged:Connect(function(_, parent)
        if not parent then
            container:Remove()
        end
    end)

    -- Drawing
    local name = drawnew("Text")
    name.Center = true
    name.Outline = true
    name.Size = self.Config.TextSize
    name.Color = config.Color
    name.Text = config.Name

    local distance = drawnew("Text")
    distance.Center = true
    distance.Outline = true
    distance.Color = col3new(1, 1, 1)
    distance.Size = self.Config.TextSize

    local health = drawnew("Text")
    health.Center = true
    health.Outline = true
    health.Color = col3new(1, 1, 1)
    health.Size = self.Config.TextSize

    local tracer = drawnew("Line")
    tracer.From = self.Config.Tracer.From
    tracer.Thickness = self.Config.Tracer.Thickness
    tracer.Color = config.Color

    local highlight = instnew("Highlight")
    highlight.Enabled = false
    highlight.FillTransparency = self.Config.Highlight.Transparency.Fill
    highlight.OutlineTransparency = self.Config.Highlight.Transparency.Outline
    highlight.FillColor = self.Config.Highlight.Color
    highlight.OutlineColor = self.Config.Highlight.Color
    highlight.Parent = config.HighlightFocus

    -- Indexing
    table_insert(drawing, { Obj = name, Name = "Name", Type = "Text" })
    table_insert(drawing, { Obj = distance, Name = "Distance", Type = "Text" })
    table_insert(drawing, { Obj = health, Name = "Health", Type = "Text" })
    table_insert(drawing, { Obj = tracer, Name = "Tracer", Type = "Line" })
    table_insert(drawing, { Obj = highlight, Name = "Highlight", Type = "Highlight" })

    self.Containers[rootPart] = container
    return container
end

function module:Remove(rootPart)
    local container = self.Containers[rootPart]
    if container then
        self.Containers[rootPart] = nil
        for i, connection in container.Connections do
            connection:Disconnect()
            container.Connections[i] = nil
        end
        for i, draw in container.Drawing do
            draw.Obj:Destroy()
            container.Drawing[i] = nil
        end
        for i, _ in container do
            container[i] = nil
        end
    end
end

function module:Clear()
    for _, container in self.Containers do
        container:Remove()
    end
end

function module:Unload()
    for i, connection in self.Connections do
        connection:Disconnect()
        self.Connections[i] = nil
    end
    self:Clear()
    for i, _ in self do
        self[i] = nil
    end
end

-- Main
local connections = module.Connections
connections.CharacterAdded = localPlayer.CharacterAdded:Connect(onCharacterAdded)
connections.Update = RunService.Stepped:Connect(function()
    local eConfig = module.Config
    local eDistance = eConfig.Distance
    local eHealth = eConfig.Health
    local eTracer = eConfig.Tracer
    local eHighlight = eConfig.Highlight
    local textSize = eConfig.TextSize

    -- Update containers
    for _, container in module.Containers do
        local config = container.Config
        local callbacks = container.Callbacks

        -- Skip hidden containers
        if config.Hidden then continue end

        -- Check if alive
        if not isAlive(container) then
            container:Remove()
            continue
        end
        
        -- Get on-screen position
        local root = container.Root
        local pos, onScreen = wtvp(localCamera, root.Position)
        if not onScreen then
            container:Toggle(false)
            continue
        end
        
        -- Check distance
        local mag = (root.Position - localRoot.Position).Magnitude
        if mag > eDistance.Max then
            container:Toggle(false)
            continue
        end

        -- Update container content
        local vec2 = vec2new(pos.X, pos.Y)
        local color = eConfig.Rainbow and col3hsv(tick() % 5 / 5, 1, 1) or config.Color
        local rows = 0
        for _, draw in container.Drawing do
            if draw.Type == "Text" and draw.Obj.Text ~= "" then
                rows += 1
            end
        end
        
        -- Update visuals
        for i = 1, #container.Drawing, 1 do
            local draw = container.Drawing[i]
            local obj = draw.Obj
            local name = draw.Name
            local ttype = draw.Type
            
            if ttype ~= "Highlight" then
                obj.Color = color
                obj.Visible = (ttype ~= "Line" or (ttype == "Line" and eTracer.Enabled))
                
                if ttype == "Text" then
                    obj.Size = textSize
                    obj.Position = vec2 - vec2new(0, (rows - i) * textSize)
    
                    if name == "Name" then
                        obj.Text = config.Name
                    
                    elseif name == "Distance" and eDistance.Enabled then
                        obj.Text = `[{math_round(mag)} studs]`

                    elseif name == "Health" and eHealth.Enabled then
                        local bool, args = checkCallback(container, "Health") -- args: health, maxHealth
                        if bool then
                            local hType = string_lower(eHealth.Type)
                            if hType == "percentage" then
                                obj.Text = `[{math_clamp(math_round(100 / args[2] * args[1] * 10) / 10, 0, 100)}%]`
                            elseif hType == "fraction" then
                                obj.Text = `[{math_round(math_max(args[1], 0))}/{math_round(args[2])}]`
                            end
                        end
                    end
                elseif ttype == "Line" then
                    obj.Visible = eTracer.Enabled
                    if eTracer.Enabled then
                        obj.From = eTracer.From
                        obj.To = vec2 + vec2new(0, math_max(rows * textSize / 2, textSize)) -- dynamic text rows offset
                        obj.Thickness = eTracer.Thickness
                    end
                end
            else
                obj.Enabled = eHighlight.Enabled
                if eHighlight.Enabled then
                    obj.FillColor = color
                    obj.OutlineColor = color
                    obj.FillTransparency = eHighlight.Transparency.Fill
                    obj.OutlineTransparency = eHighlight.Transparency.Outline
                    obj.DepthMode = (eHighlight.AlwaysOnTop and "AlwaysOnTop" or "Occluded")
                end
            end
        end

        -- Update container hidden after update
        if container.Config.Hidden then
            container:Toggle(true)
        end
    end
end)
getgenv().Vynixu_ESPModule = module
return module
