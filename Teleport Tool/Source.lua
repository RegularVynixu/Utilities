-- Services

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local MS = game:GetService("MarketplaceService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character
local Root = Char:WaitForChild("HumanoidRootPart")

local TeleportTool = { Points = {} }

-- Modules

local SelfModules = {
	Directory = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Directory.lua"))(),
}

-- Directory Setup

local Directory = SelfModules.Directory.Create({ "Vynixu's Teleport Tool" })

-- Misc Functions

local function onCharacterAdded(char)
	Char, Root = char, char:WaitForChild("HumanoidRootPart")
end

local function updateVisual()
	for i, v in next, TeleportTool.Points do
		local prevPoint = TeleportTool.Points[i - 1]

		if prevPoint and prevPoint:FindFirstChild("Beam") then
			prevPoint.Beam.Attachment1 = v.Attachment
		end
	end
end

-- Functions

TeleportTool.Add = function(self, vec3)
	if #self.Points > 0 then
		local point, nearest = nil, 2

		for i, v in next, self.Points do
			local dist = (v.Position - vec3).Magnitude

			if dist < nearest then
				point, nearest = v, dist
			end
		end

		if point ~= nil then
			point.Position = vec3; return
		end
	end

	-- Point
	
	local point = Instance.new("Part")
	point.Anchored = true
	point.CanCollide = false
	point.Color = Color3.new(1, 1, 1)
	point.Material = Enum.Material.Neon
	point.Position = vec3
	point.Shape = Enum.PartType.Ball
	point.Size = Vector3.new(0.4, 0.4, 0.4)
	
	local attachment = Instance.new("Attachment")
	attachment.Parent = point
	
	-- ClickDetector

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = math.huge

	clickDetector.MouseHoverEnter:Connect(function()
		point.Color = Color3.new(1, 0, 0)
	end)

	clickDetector.MouseHoverLeave:Connect(function()
		point.Color = Color3.new(1, 1, 1)
	end)
	
	clickDetector.MouseClick:Connect(function()
		TeleportTool:Remove(point)
	end)

	clickDetector.Parent = point
	
	-- Indexing

	table.insert(self.Points, point)

	local prevPoint = self.Points[#self.Points - 1]
	if prevPoint ~= nil then
		-- Beam
		
		local beam = Instance.new("Beam")
		beam.Brightness = 5
		beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)) })
		beam.FaceCamera = true
		beam.Width0, beam.Width1 = 0.1, 0.1
		beam.Attachment0, beam.Attachment1 = prevPoint.Attachment, attachment

		beam.Parent = prevPoint
	end

	point.Parent = workspace
end

TeleportTool.Remove = function(self, point)
	table.remove(self.Points, table.find(self.Points, point)); point:Destroy()
	updateVisual()
end

TeleportTool.Clear = function(self)
	for i = #self.Points, 1, -1 do
		self:Remove(self.Points[i])
	end
end

TeleportTool.Save = function(self)
	if #self.Points > 0 then
		local output = "local Points = { "
		
		for i, v in next, self.Points do
			output = output.. "Vector3.new(".. (math.round(v.Position.X * 100) / 100).. ", ".. (math.round(v.Position.Y * 100) / 100).. ", ".. (math.round(v.Position.Z * 100) / 100).. ")".. (i ~= #self.Points and ", " or " ")
		end

		writefile(Directory.Root.. "/".. MS:GetProductInfo(game.PlaceId).Name.. ".lua", output.. "}\n\n".. game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Teleport%20Tool/Output.lua"))
	end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed == false then
		if input.KeyCode == Enum.KeyCode.KeypadMinus then
			TeleportTool:Add(Root.Position)
			
		elseif input.KeyCode == Enum.KeyCode.KeypadPlus then
			TeleportTool:Save()

		elseif input.KeyCode == Enum.KeyCode.KeypadMultiply then
			TeleportTool:Clear()
		end
	end
end)

onCharacterAdded(Char)
Plr.CharacterAdded:Connect(onCharacterAdded, char)

-- Scripts

return TeleportTool
