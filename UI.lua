-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Variables
local localPlayer = Players.LocalPlayer
local localMouse = localPlayer:GetMouse()

local ui = {
    Color = {
        Add = function(c1, c2)
            local r = math.min((c1.R + c2.R) * 255, 255)
            local g = math.min((c1.G + c2.G) * 255, 255)
            local b = math.min((c1.B + c2.B) * 255, 255)
            return Color3.fromRGB(r, g, b)
        end,
        Sub = function(c1, c2)
            local r = math.max((c1.R - c2.R) * 255, 0)
            local g = math.max((c1.G - c2.G) * 255, 0)
            local b = math.max((c1.B - c2.B) * 255, 0)
            return Color3.fromRGB(r, g, b)
        end,
        ToFormat = function(c)
            local r = math.floor(math.min(c.R * 255, 255))
            local g = math.floor(math.min(c.G * 255, 255))
            local b = math.floor(math.min(c.B * 255, 255))
            return ("rgb(%d, %d, %d)"):format(r, g, b)
        end
    }
}

-- Functions
ui.Create = function(class, properties, radius)
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

ui.MakeDraggable = function(obj, dragObj, smoothness)
    local startPos = nil
    local dragging = false
    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = Vector2.new(localMouse.X - obj.AbsolutePosition.X, localMouse.Y - obj.AbsolutePosition.Y)
        end
    end)
    dragObj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    localMouse.Move:Connect(function()
        if dragging then
            TweenService:Create(obj, TweenInfo.new(math.clamp(smoothness, 0, 1), Enum.EasingStyle.Sine), { Position = UDim2.new(0, localMouse.X - startPos.X, 0, localMouse.Y - startPos.Y) }):Play()
        end
    end)
end

-- Main
return ui
