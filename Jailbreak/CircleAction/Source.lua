-- UI Construction

local MainGui = Instance.new("ScreenGui")
local CircleA = Instance.new("Frame")
local Circle = Instance.new("ImageLabel")
local Outer = Instance.new("ImageLabel")
local TextLabel = Instance.new("TextLabel")
local Outer2 = Instance.new("ImageLabel")
local OuterFull = Instance.new("ImageLabel")
local Help = Instance.new("TextLabel")
local Hold = Instance.new("TextLabel")

MainGui.Name = "MainGui"
MainGui.Parent = game:GetService("CoreGui")
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

CircleA.Name = "CircleAction"
CircleA.Parent = MainGui
CircleA.AnchorPoint = Vector2.new(0.5, 0.5)
CircleA.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CircleA.BackgroundTransparency = 1
CircleA.Position = UDim2.new(0.5, -32, 0.5, -32)
CircleA.Size = UDim2.new(0, 64, 0, 64)

Circle.Name = "Circle"
Circle.Parent = CircleA
Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Circle.BackgroundTransparency = 1
Circle.BorderSizePixel = 0
Circle.Size = UDim2.new(1, 0, 1, 0)
Circle.ZIndex = 3
Circle.Image = "rbxassetid://819379657"

Outer.Name = "Outer"
Outer.Parent = CircleA
Outer.AnchorPoint = Vector2.new(0.5, 0.5)
Outer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Outer.BackgroundTransparency = 1
Outer.BorderSizePixel = 0
Outer.Position = UDim2.new(0.5, 0, 0.5, 0)
Outer.Size = UDim2.new(1, 16, 1, 16)
Outer.Visible = false
Outer.Image = "rbxassetid://819520293"
Outer.ImageColor3 = Color3.fromRGB(214, 214, 214)

TextLabel.Parent = CircleA
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.ZIndex = 4
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = "E"
TextLabel.TextColor3 = Color3.fromRGB(93, 93, 93)
TextLabel.TextScaled = true
TextLabel.TextSize = 48
TextLabel.TextStrokeColor3 = Color3.fromRGB(202, 202, 202)
TextLabel.TextStrokeTransparency = 0.800
TextLabel.TextTransparency = 0.400
TextLabel.TextWrapped = true

Outer2.Name = "Outer2"
Outer2.Parent = CircleA
Outer2.AnchorPoint = Vector2.new(0.5, 0.5)
Outer2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Outer2.BackgroundTransparency = 1
Outer2.BorderSizePixel = 0
Outer2.Position = UDim2.new(0.5, 0, 0.5, 0)
Outer2.Rotation = 90
Outer2.Size = UDim2.new(1, 16, 1, 16)
Outer2.Visible = false
Outer2.ZIndex = 2
Outer2.Image = "rbxassetid://819520293"
Outer2.ImageColor3 = Color3.fromRGB(214, 214, 214)

OuterFull.Name = "OuterFull"
OuterFull.Parent = CircleA
OuterFull.AnchorPoint = Vector2.new(0.5, 0.5)
OuterFull.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OuterFull.BackgroundTransparency = 1
OuterFull.BorderSizePixel = 0
OuterFull.Position = UDim2.new(0.5, 0, 0.5, 0)
OuterFull.Size = UDim2.new(1, 16, 1, 16)
OuterFull.Image = "rbxassetid://819379657"
OuterFull.ImageColor3 = Color3.fromRGB(214, 214, 214)

Help.Name = "Help"
Help.Parent = CircleA
Help.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Help.BackgroundTransparency = 1
Help.BorderSizePixel = 0
Help.Position = UDim2.new(0.5, -50, 1, 10)
Help.Size = UDim2.new(0, 100, 0, 20)
Help.Font = Enum.Font.SourceSans
Help.Text = "Placeholder"
Help.TextColor3 = Color3.fromRGB(255, 255, 255)
Help.TextSize = 30
Help.TextStrokeTransparency = 0.800

Hold.Name = "Hold"
Hold.Parent = CircleA
Hold.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Hold.BackgroundTransparency = 1
Hold.BorderSizePixel = 0
Hold.Position = UDim2.new(0, 0, 0.100000001, 0)
Hold.Size = UDim2.new(1, 0, 0.100000001, 0)
Hold.ZIndex = 4
Hold.Font = Enum.Font.SourceSansBold
Hold.Text = "hold"
Hold.TextColor3 = Color3.fromRGB(93, 93, 93)
Hold.TextSize = 12
Hold.TextStrokeColor3 = Color3.fromRGB(202, 202, 202)
Hold.TextTransparency = 0.400

-- Services

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")


-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local CircleAction = { Frame = CircleA, Spec = nil, Specs = {} }

-- Misc Functions

local function toggleSpec(bool, finished)
	local posOffset = bool and -4 or -8
	local sizeOffset = bool and 8 or 16

	for _, v in next, { CircleAction.Frame.Outer, CircleAction.Frame.Outer2 } do
		v.Size = UDim2.new(1, sizeOffset, 1, sizeOffset)
		v.Visible = bool
	end

	CircleAction.Frame.OuterFull.Visible = not bool
	
	if finished then
		if typeof(CircleAction.Spec.Callback) == "function" then
			local success, result = pcall(CircleAction.Spec.Callback)
			
			if not success or result == false then
				CircleAction.Spec.Red = true
			end
		end
		
		CircleAction.Frame.OuterFull.Size = UDim2.new(1, 0, 1, 0)
		
		TS:Create(CircleAction.Frame.OuterFull, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(1, 26, 1, 26), ImageColor3 = Color3.fromRGB(CircleAction.Spec.Red and 254 or 214, 214, 214) }):Play(); task.wait(0.2)
		
		if CircleAction.Frame.OuterFull.Size.X.Offset == 26 then
			TS:Create(CircleAction.Frame.OuterFull, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Size = UDim2.new(1, 16, 1, 16), ImageColor3 = Color3.fromRGB(214, 214, 214) }):Play(); task.wait(0.2)
		end
		
		CircleAction.Spec.Red = nil
	end
end

local function interactSpec()
	if CircleAction.Spec then
		toggleSpec(true)

		local startTick = tick()
		local angle = 0

		if CircleAction.Spec.Timed then
			repeat
				angle = math.clamp((tick() - startTick) / CircleAction.Spec.Duration, 0, 1)
				CircleAction.Frame.Outer.Rotation = 90 * angle + 90 + 180 * angle
				CircleAction.Frame.Outer2.Rotation = 270 * angle + 90 + 180 * angle
				
				local sizeIncr = 4 * angle + 4
				CircleAction.Frame.Outer.Size = UDim2.new(1, 2 * sizeIncr, 1, 2 * sizeIncr)
				CircleAction.Frame.Outer2.Size = UDim2.new(1, 2 * sizeIncr, 1, 2 * sizeIncr)
				
				local outerColor = 214 - 64 * (1 - angle)
				CircleAction.Frame.Outer.ImageColor3 = Color3.fromRGB(outerColor, outerColor, outerColor)
				CircleAction.Frame.Outer2.ImageColor3 = Color3.fromRGB(outerColor, outerColor, outerColor)

				RS.Stepped:Wait()
			until (not UIS:IsKeyDown(Enum.KeyCode.E) and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) or angle == 1 or not CircleAction.Spec
		end

		toggleSpec(false, angle == 1 or (CircleAction.Spec and not CircleAction.Spec.Timed))
	end
end

-- Functions

function CircleAction.Add(spec)
	assert(spec.Name, "No name assigned")
	assert(spec.Part, "No part assigned")
	
	if typeof(spec.Dist) == "number" then
		spec.Dist = math.min(spec.Dist, 100)
	end

	if not spec.Priority then
		spec.Priority = 1
	end
	
	if spec.Timed and typeof(spec.Duration) ~= "number" then
		spec.Duration = 1
	end

	table.insert(CircleAction.Specs, spec)

	return function()
		return CircleAction.Remove(spec)
	end
end

function CircleAction.Remove(spec)
	for i, v in next, CircleAction.Specs do
		if v == spec then
			table.remove(CircleAction.Specs, i); return true
		end
	end

	return false
end

-- Scripts

RS.Stepped:Connect(function()
	local specs, spec = {}, nil
		
	for _, v in next, CircleAction.Specs do
		if v.Enabled and v.Part and v.Dist then
			if (v.Part.Position - Root.Position).Magnitude <= v.Dist then
				specs[#specs + 1] = v
			end
		end
	end
	
	if #specs > 0 then
		table.sort(specs, function(a, b)
			return a.Priority > b.Priority
		end)
		spec = specs[1]
		
		local screenPoint = Camera:WorldToViewportPoint(spec.Part.Position)
		
		CircleAction.Frame.Help.Text = spec.Name
		CircleAction.Frame.Hold.Visible = spec.Timed
		CircleAction.Frame.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y)
	end
	
	CircleAction.Frame.Visible = spec ~= nil
	CircleAction.Spec = spec
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
		interactSpec()
	end
end)

CircleAction.Frame.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		interactSpec()
	end
end)

return CircleAction
