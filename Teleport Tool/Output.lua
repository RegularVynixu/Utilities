local Player = game:GetService("Players").LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")

local function teleportToPoint(vec3, speed)
	local bV = Instance.new("BodyVelocity")
	bV.Velocity, bV.MaxForce = Vector3.new(), Vector3.new(9e9, 9e9, 9e9); bV.Parent = Root

	local reached = false
	local connection = game:GetService("RunService").Stepped:Connect(function(_, step)
		local diff = vec3 - Root.Position
		Root.CFrame = CFrame.new(Root.Position + diff.Unit * math.min(speed * step, diff.Magnitude))
		
		if (Vector3.new(vec3.X, 0, vec3.Z) - Vector3.new(Root.Position.X, 0, Root.Position.Z)).Magnitude < 0.1 then
			Root.CFrame = CFrame.new(vec3)
            
            reached = true
		end
	end)

	repeat task.wait() until reached

	connection:Disconnect()
    bV:Destroy()
end

for _, v in next, Points do
	teleportToPoint(v, 25)
end
