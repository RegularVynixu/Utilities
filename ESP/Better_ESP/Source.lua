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
local math_min = math.min
local math_max = math.max
local math_floor = math.floor
local math_clamp = math.clamp
local table_insert = table.insert
local string_lower = string.lower

local module = {
    Containers = {},
    Connections = {},
    Config = {
        TextSize = 16,
        Rainbow = false,
        ColorOverride = nil,
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

local function getCallback(container, key)
    local callback = container.Callbacks[key]
    return typeof(callback) == "function" and {callback()} or {}
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
    table_insert(drawing, { Obj = name, Name = "Name", Type = "Text", Order = 1 })
    table_insert(drawing, { Obj = distance, Name = "Distance", Type = "Text", Order = 2})
    table_insert(drawing, { Obj = health, Name = "Health", Type = "Text", Order = 3})
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
    self:Clear()
    for i, connection in self.Connections do
        connection:Disconnect()
        self.Connections[i] = nil
    end
    for i, _ in self do
        self[i] = nil
    end
    getgenv().Vynixu_ESPModule = nil
end

-- Main
local connections = module.Connections
connections.CharacterAdded = localPlayer.CharacterAdded:Connect(onCharacterAdded)
connections.Update = RunService.RenderStepped:Connect(function()
    local eConfig = module.Config
    local eDistance = eConfig.Distance
    local eHealth = eConfig.Health
    local eTracer = eConfig.Tracer
    local eHighlight = eConfig.Highlight
    local textSize = eConfig.TextSize

    -- Update containers
    for _, container in module.Containers do
        local config = container.Config
        local drawing = container.Drawing
        local callbacks = container.Callbacks
        local shouldHide = false
        
        -- Check if alive
        if not isAlive(container) then
            container:Remove()
            continue
        end

        -- Get on-screen position
        local root = container.Root
        local pos, onScreen = wtvp(localCamera, root.Position)
        if not onScreen then
            shouldHide = true
        end
        
        -- Check distance
        local mag = (root.Position - localRoot.Position).Magnitude
        if mag > eDistance.Max then
            shouldHide = true
        end

        if shouldHide then
            -- Hide container
            if not config.Hidden then
                config.Hidden = true
                for i2 = 1, #drawing, 1 do
                    local draw = drawing[i2]
                    if draw.Type ~= "Highlight" then
                        draw.Obj.Visible = false
                    else
                        draw.Obj.Enabled = false
                    end
                end
            end
            continue
        else
            config.Hidden = false

            -- Update container
            local vec2 = vec2new(pos.X, pos.Y)
            local color = typeof(eConfig.ColorOverride == "Color3") and eConfig.ColorOverride or eConfig.Rainbow and col3hsv(tick() % 4 / 4, 1, 1) or config.Color
            local textRows = 0
            
            -- Get text rows count
            for i = 1, #drawing, 1 do
                local draw = drawing[i]
                if draw.Type == "Text" and draw.Obj.Text ~= "" then
                    textRows += 1
                end
            end
            
            for i = 1, #drawing, 1 do
                local draw = drawing[i]
                local obj = draw.Obj
                local name = draw.Name
                local ttype = draw.Type

                if ttype == "Text" then
                    if name == "Name" then
                        obj.Text = config.Name

                    elseif name == "Distance" then
                        obj.Text = eDistance.Enabled and `[{math_floor(mag)} studs]` or ""

                    elseif name == "Health" then
                        local text;
                        if eHealth.Enabled then
                            local args = getCallback(container, "Health")
                            if #args > 1 then
                                local hType = string_lower(eHealth.Type)
                                if hType == "percentage" then
                                    text = `[{math_clamp(math_floor(100 / args[2] * args[1] * 10) / 10, 0, 100)}%]`
                                elseif hType == "fraction" then
                                    text = `[{math_floor(math_max(args[1], 0))}/{math_floor(args[2])}]`
                                end
                            end
                        end
                        obj.Text = text or ""
                    end
                    obj.Size = textSize
                    obj.Position = vec2 - vec2new(0, (textRows - math_min(textRows, draw.Order)) * textSize) -- dynamically order text positions (dogshit lol)
                    obj.Visible = true

                elseif ttype == "Line" then
                    local enabled = eTracer.Enabled
                    if enabled then
                        obj.From = eTracer.From
                        obj.To = vec2 + vec2new(0, math_max(textRows * textSize / 2, textSize)) -- always under last text row
                        obj.Thickness = eTracer.Thickness
                    end
                    obj.Visible = enabled
                
                elseif ttype == "Highlight" then
                    local enabled = eHighlight.Enabled
                    if enabled then
                        obj.FillColor = color
                        obj.FillTransparency = eHighlight.Transparency.Fill
                        obj.OutlineColor = color
                        obj.OutlineTransparency = eHighlight.Transparency.Outline
                        obj.DepthMode = eHighlight.AlwaysOnTop and "AlwaysOnTop" or "Occluded"
                    end
                    obj.Enabled = enabled
                end
            end
        end
    end
end)
getgenv().Vynixu_ESPModule = module
return module
