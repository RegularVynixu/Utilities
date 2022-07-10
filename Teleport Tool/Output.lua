local Root = game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local RS = game:GetService("RunService")

local function teleportToPoint(vec3, speed)
	local bV = Instance.new("BodyVelocity")
	bV.Velocity, bV.MaxForce = Vector3.new(), Vector3.new(9e9, 9e9, 9e9); bV.Parent = Root

	local reached, connection = false, nil
	connection = RS.Stepped:Connect(function(_, step)
		local diff = (vec3 - Root.Position)
		Root = CFrame.new(Root.Position + diff.Unit * math.min(speed * step, diff.Magnitude))
		
		if (Vector3.new(vec3.X, 0, vec3.Z) - Vector3.new(Root.Position.X, 0, Root.Position.Z)) < 0.1 then
			Root.CFrame = CFrame.new(vec3); reached = true
		end
	end)

	repeat RS.RenderStepped:Wait() until reached == true
	connection:Disconnect(); bV:Destroy()
end

for i, v in next, Points do
	teleportToPoint(v, 25)
end
