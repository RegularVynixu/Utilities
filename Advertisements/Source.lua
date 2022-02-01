-- Services

local CG = game:GetService("CoreGui")
local GS = game:GetService("GuiService")
local TS = game:GetService("TweenService")

-- Variables

local Advertisements = {
	Active = {},
}
local Modules = {
    Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Utils.lua"))(),
	Inviter = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Discord%20Inviter/Source.lua"))(),
}
local PropertyIgnores = {"Parent", "Position", "Visible"}

local Camera = workspace.CurrentCamera

-- Local Functions

local function PositionAdvertisement(advertisement, udim2)
	if not advertisement.Holder then
		return
	end
	
    local maxX = Camera.ViewportSize.X - advertisement.Holder.AbsoluteSize.X
    local maxY = Camera.ViewportSize.Y - advertisement.Holder.AbsoluteSize.Y - GS:GetGuiInset().Y
    advertisement.Holder.Position = UDim2.new(0, math.min(udim2.X.Offset, maxX), 0, math.min(udim2.Y.Offset, maxY))
end

-- Functions

function Advertisements:Add(info, properties)
	assert(info.Image)
	
	-- UI Construction
	
	if not Advertisements.Gui then
		Advertisements.Gui = Modules.Utils:Create("ScreenGui", {
			Name = "Advertisements",
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		})
		Advertisements.Gui.Parent = CG
	end

	local advertisement = {
        active = true,
		connections = {},
	}
	
	advertisement.Holder = Modules.Utils:Create("ImageButton", {
		Name = "Holder",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = properties.Size,
        Visible = false,
	}, UDim.new(0, 5))
	
	advertisement.Close = Modules.Utils:Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 0, 17),
        Font = Enum.Font.SciFi,
        Text = "x",
        TextColor3 = Color3.fromRGB(205, 25, 25),
        TextSize = 20,
        TextStrokeTransparency = .75,
        TextWrapped = true,
	})
	
	advertisement.Holder.Parent = Advertisements.Gui
	advertisement.Close.Parent = advertisement.Holder
	
	-- Setup
	
	Advertisements.Active[#Advertisements.Active + 1] = advertisement

    PositionAdvertisement(advertisement, UDim2.new(0, math.random(Camera.ViewportSize.X), 0, math.random(Camera.ViewportSize.Y)))
    advertisement.Holder.Image = Modules.Utils:LoadCustomAsset(info.Image)
	for i, v in next, properties do
		if not table.find(PropertyIgnores, i) then
            advertisement.Holder[i] = v
        end
	end
		
	if info.Invite then
		advertisement.connections.Interact = advertisement.Holder.MouseButton1Down:Connect(function(input, processed)
			Modules.Inviter.Join(info.Invite)
		end)
	end

	advertisement.connections.Close = advertisement.Close.MouseButton1Click:Connect(function()
		Advertisements:Remove(advertisement)
	end)

    advertisement.Holder.Visible = true

	-- Scripts
	
	task.wait(info.Duration and math.min(info.Duration, 30) or 10)
	Advertisements:Remove(advertisement)
end

function Advertisements:Remove(advertisement)
	if not advertisement.active then
		return
	end
    advertisement.active = false
	
	advertisement.Close:Destroy()
	advertisement.Close = nil

    TS:Create(advertisement.Holder, TweenInfo.new(3), {
        ImageTransparency = 1,
    }):Play()
    task.wait(5)

    for i, v in next, advertisement.connections do
		v:Disconnect()
		v = nil
	end

	advertisement.Holder:Destroy()
	advertisement.Holder = nil
	Advertisements.Active[table.find(Advertisements.Active, advertisement)] = nil
end

-- Scripts

return Advertisements
