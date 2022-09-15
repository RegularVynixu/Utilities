local Points = {}

local NetworkClient = game:GetService("NetworkClient")
local RunService = game:GetService("RunService")
local LocalPlayer = NetworkClient:GetPlayer()

local function TeleportToPoint(position, speed)
	local p = position * Vector3.new(1, 0, 1)
	if typeof(LocalPlayer) == 'Instance' then
		local Character = LocalPlayer.Character
		local Humanoid = typeof(Character) == 'Instance' and Character:FindFirstChildWhichIsA("Humanoid")
		local HumanoidRootPart = typeof(Humanoid) == 'Instance' and Humanoid.RootPart
		if typeof(HumanoidRootPart) == 'Instance' then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Velocity = Vector3.zero
			BodyVelocity.MaxForce = Vector3.one * 9e9
			BodyVelocity.Parent = HumanoidRootPart
			
			local reached = false
			local connection; connection = RunService.Stepped:Connect(function(time, deltaTime)
				local diff = (position - HumanoidRootPart.Position)
				HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position + diff.Unit * math.min(speed * deltaTime, diff.Magnitude))
				if (p - (HumanoidRootPart.Position * Vector3.new(1, 0, 1))).Magnitude < .1 then
					HumanoidRootPart.CFrame = CFrame.new(position)
					reached = true
				end
			end)
			while reached ~= true and typeof(connection) == 'RBXScriptConnection' and typeof(BodyVelocity) == 'Instance' do
				RunService.Stepped:Wait()
			end
			if typeof(connection) == 'RBXScriptConnection' then
				connection:Disconnect()
			end
			if typeof(BodyVelocity) == 'Instance' then
				BodyVelocity:Destroy()
			end
		end
	end
end

for _, Point in pairs(Points) do
	TeleportToPoint(Point, 25)
end
