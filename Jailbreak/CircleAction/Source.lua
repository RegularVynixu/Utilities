-- Services

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera
local WorldToScreenPoint = Camera.WorldToScreenPoint

local SelfModules = {
	UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/UI.lua"))(),
}

local CircleAction = { Spec = nil, Specs = {} }

-- Misc Functions

local function toggle(bool, finished)
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

local function interact()
	if CircleAction.Spec then
		toggle(true)

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

		toggle(false, angle == 1 or (CircleAction.Spec and not CircleAction.Spec.Timed))
	end
end

-- Functions

function CircleAction.Add(spec)
	assert(spec.Name, "No name assigned")
	assert(spec.Part, "No part assigned")
	assert(typeof(spec.Callback) == "function", "No callback assigned")

    if spec.Enabled == nil then
        spec.Enabled = true
    end
	if not spec.Dist then
		spec.Dist = math.clamp(spec.Dist, 0, 100)
	end
	if not spec.Priority then
		spec.Priority = 1
	end
	if spec.Timed and not spec.Duration then
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

-- UI Construction

local ScreenGui = SelfModules.UI.Create("ScreenGui", {
    Name = "CircleActionGui",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

CircleAction.Frame = SelfModules.UI.Create("Frame", {
    Name = "CircleAction",
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, -32, 0.5, -32),
    Size = UDim2.new(0, 64, 0, 64),

    SelfModules.UI.Create("ImageLabel", {
        Name = "Circle",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        Image = "rbxassetid://819379657",
    }),

    SelfModules.UI.Create("ImageLabel", {
        Name = "Outer",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 16, 1, 16),
        Visible = false,
        Image = "rbxassetid://819520293",
        ImageColor3 = Color3.fromRGB(214, 214, 214),
    }),

    SelfModules.UI.Create("ImageLabel", {
        Name = "Outer2",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = 90,
        Size = UDim2.new(1, 16, 1, 16),
        Visible = false,
        ZIndex = 2,
        Image = "rbxassetid://819520293",
        ImageColor3 = Color3.fromRGB(214, 214, 214),
    }),

    SelfModules.UI.Create("ImageLabel", {
        Name = "OuterFull",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 16, 1, 16),
        Image = "rbxassetid://819379657",
        ImageColor3 = Color3.fromRGB(214, 214, 214),
    }),

    SelfModules.UI.Create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 4,
        Font = Enum.Font.SourceSansBold,
        Text = "E",
        TextColor3 = Color3.fromRGB(93, 93, 93),
        TextScaled = true,
        TextSize = 48,
        TextStrokeColor3 = Color3.fromRGB(202, 202, 202),
        TextStrokeTransparency = 0.8,
        TextTransparency = 0.4,
        TextWrapped = true,
    }),

    SelfModules.UI.Create("TextLabel", {
        Name = "Hold",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.1, 0),
        Size = UDim2.new(1, 0, 0.1, 0),
        ZIndex = 4,
        Font = Enum.Font.SourceSansBold,
        Text = "hold",
        TextColor3 = Color3.fromRGB(93, 93, 93),
        TextSize = 12,
        TextStrokeColor3 = Color3.fromRGB(202, 202, 202),
        TextTransparency = 0.4,
    }),

    SelfModules.UI.Create("TextLabel", {
        Name = "Help",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -50, 1, 10),
        Size = UDim2.new(0, 100, 0, 20),
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 30,
        TextStrokeTransparency = 0.8,
    }),
})

CircleAction.Frame.Parent = ScreenGui
ScreenGui.Parent = CG

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
		
		local screenPoint = WorldToScreenPoint(Camera, spec.Part.Position)
		
		CircleAction.Frame.Help.Text = spec.Name
		CircleAction.Frame.Hold.Visible = spec.Timed
		CircleAction.Frame.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y)
	end
	
	CircleAction.Frame.Visible = spec ~= nil
	CircleAction.Spec = spec
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
		interact()
	end
end)

CircleAction.Frame.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		interact()
	end
end)

return CircleAction
