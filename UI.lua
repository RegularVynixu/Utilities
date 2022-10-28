-- Services

local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Variables

local Plr = Players.LocalPlayer
local Mouse = Plr:GetMouse()

local UI = {
    Color = {
        Add = function(c1, c2)
            local r, g, b = c1.R + c2.R, c1.G + c2.G, c1.B + c2.B
            return Color3.fromRGB(math.min(r * 255, 255), math.min(g * 255, 255), math.min(b * 255, 255))
        end,
        Sub = function(c1, c2)
            local r, g, b = c1.R - c2.R, c1.G - c2.G, c1.B - c2.B
            return Color3.fromRGB(math.max(r * 255, 0), math.max(g * 255, 0), math.max(b * 255, 0))
        end,
        ToFormat = function(color3)
            return "rgb(".. math.floor(math.min(color3.R * 255, 255)).. ", ".. math.floor(math.min(color3.G * 255, 255)).. ", ".. math.floor(math.min(color3.B * 255, 255)).. ")"
        end,
    },
}

-- Functions

UI.Create = function(class, properties, radius)
	local instance = Instance.new(class)

	for i, v in next, properties do
		if i ~= "Parent" then
			if typeof(v) == "Instance" then
				v.Parent = instance
			else
				instance[i] = v
			end
		end
	end

	if radius then
		local uicorner = Instance.new("UICorner", instance)
		uicorner.CornerRadius = radius
	end
    
	return instance
end

UI.MakeDraggable = function(obj, drag, smoothness)
    local startPos, dragging = nil, false

    drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = Vector2.new(Mouse.X - obj.AbsolutePosition.X, Mouse.Y - obj.AbsolutePosition.Y)
        end
    end)

    drag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    Mouse.Move:Connect(function()
        if dragging then
            TS:Create(obj, TweenInfo.new(math.clamp(smoothness, 0, 1), Enum.EasingStyle.Sine), { Position = UDim2.new(0, Mouse.X - startPos.X, 0, Mouse.Y - startPos.Y) }):Play()
        end
    end)
end

-- Scripts

return UI
