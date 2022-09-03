-- Services

local Players = game:GetService("Players")

-- Variables

local Plr = Players.LocalPlayer

local Notification = { Queue = {}, Color = Color3.fromRGB(42, 204, 255) }

-- Misc Functions

local function create(class, properties, radius)
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

local function playSound(id, source, properties)
	properties = properties or {}
	
	local sound = Instance.new("Sound")
	
	for i, v in next, properties do
		if not table.find({"Parent", "PlayOnRemove"}, i) then
			sound[i] = v
		end
	end
	
	sound.SoundId = "rbxassetid://".. id; sound.PlayOnRemove = true
	sound.Parent = source; sound:Destroy(); sound = nil
end

-- Functions

function Notification.setColor(color)
	Notification.Color = color
	Notification.Gui.ContainerNotification.ImageColor3 = color
end

function Notification.new(data)
	assert(typeof(data) == "table" and data.Text)
	
	if Notification.Gui.Enabled then
		table.insert(Notification.Queue, data); return
	end
	
	if typeof(data.Color) == "Color3" then
		Notification.setColor(data.Color)
	end
	
	Notification.Gui.ContainerNotification.Message.Text = ""
	Notification.Gui.Enabled = true
	playSound(700153902, Notification.Gui, { Volume = 0.25 })

	local v1 = 1
	for i = 1, #data.Text, 1 do
		Notification.Gui.ContainerNotification.Message.Text = Notification.Gui.ContainerNotification.Message.Text.. string.sub(data.Text, i, i)
		
		if v1 == 1 then
			playSound(215658476, Notification.Gui, {})
		end;
		
		v1 = v1 % 3 + 1; task.wait(0.02)
	end
	
	task.delay(data.Duration or 1, function()
		Notification.Gui.Enabled = false

		if #Notification.Queue > 0 then
			local v2 = Notification.Queue[1]
			table.remove(Notification.Queue, 1)
			
			Notification.new(v2)
		end
	end)
end

-- UI Construction

Notification.Gui = create("ScreenGui", {
	Name = "NotificationGui",
	Enabled = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	
	create("ImageLabel", {
		Name = "ContainerNotification",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0, 350, 0, 70),
		Image = "rbxassetid://4915091158",
		ImageColor3 = Notification.Color,
		
		create("TextLabel", {
			Name = "Message",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 35, 0, 11),
			Size = UDim2.new(1, -70, 1, -22),
			Font = Enum.Font.SourceSansItalic,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 30,
			TextWrapped = true,
			
			create("UITextSizeConstraint", {
				MaxTextSize = 30,
				MinTextSize = 5,
			}),
		}),
		
		create("UIAspectRatioConstraint", {
			AspectRatio = 5,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),
	}),
	
	create("UIPadding", {
		PaddingTop = UDim.new(0.1, 0),
	}),
})

Notification.Gui.Parent = Plr.PlayerGui

-- Scripts

if Plr.Team ~= nil then
	Notification.setColor(Plr.TeamColor.Color)
end

Plr:GetPropertyChangedSignal("Team"):Connect(function()
	if Plr.Team ~= nil then
		Notification.setColor(Plr.TeamColor.Color)
	end
end)

return Notification
