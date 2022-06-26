-- Services

local CG = game:GetService("CoreGui")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")

-- Variables

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/UI.lua"))()
local Exploit = { Request = http_request or request or syn and syn.request }

local ScreenGui = UI.Create("ScreenGui", {
	Name = "Vynixu's Discord Inviter",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
ScreenGui.Parent = CG

local Inviter = { Gui = ScreenGui, Connections = {} }

-- Misc Functions

local function getCode(invite)
	if string.find(invite, "/") then
		for i = #invite, 1, -1 do
			local char = string.sub(invite, i, i)
			if char == "/" then
				return string.sub(invite, i + 1, #invite)
			end
		end
	end

	return invite
end

local function toggle(prompt, bool)
	if bool then
		prompt.Frame.Visible = true

		TS:Create(prompt.Frame, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 300, 0, 300) }):Play()
		TS:Create(prompt.Frame.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(0, 7) }):Play()
		task.wait(1)
		TS:Create(prompt.Frame.ServerIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 0, ImageTransparency = 0 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.Label, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.ServerName, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.Join, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.Ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(1)
	else
		TS:Create(prompt.Frame.Ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.Join, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.ServerName, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.Label, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TS:Create(prompt.Frame.ServerIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, ImageTransparency = 1 }):Play()
		task.wait(1)
		TS:Create(prompt.Frame, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 0, 0, 0) }):Play()
		TS:Create(prompt.Frame.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(1, 0) }):Play()
		task.wait(1)

		prompt.Frame.Visible = false
	end
end

local function disconnect(prompt)
	local connections = Inviter.Connections[prompt]

	if connections then
		for i, v in next, connections do
			v:Disconnect()
			connections[i] = nil
		end

		prompt.Frame.Ignore.Line.Visible = false
	end
end

local function remove(prompt)
	disconnect(prompt)
	
	prompt.Frame:Destroy()
	prompt = nil
end

-- Functions

Inviter.Join = function(invite)
	local success, inviteData = pcall(function()
		return HS:JSONDecode(Exploit.Request({ Url = "https://ptb.discord.com/api/invites/".. getCode(invite), Method = "GET" }).Body)
	end)
	
	if success then
		Exploit.Request({
			Url = "http://127.0.0.1:6463/rpc?v=1",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Origin"] = "https://discord.com"
			},
			Body = HS:JSONEncode({
				cmd = "INVITE_BROWSER",
				args = {
					code = inviteData.code
				},
				nonce = HS:GenerateGUID(false)
			})
		})
	end
end

Inviter.Prompt = function(invite)
	local success, inviteData = pcall(function()
		return HS:JSONDecode(Exploit.Request({ Url = "https://ptb.discord.com/api/invites/".. getCode(invite), Method = "GET" }).Body)
	end)

	if not success then
		error("Something went wrong while attempting to obtain invite data. Check if invite is valid.")
		return
	end
	
	local Prompt = { Invite = inviteData.code }

	Prompt.Frame = UI.Create("Frame", {
		Name = "Background",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(55, 55, 65),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		Visible = false,

		UI.Create("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 110),
			Size = UDim2.new(1, -20, 0, 14),
			Font = Enum.Font.SourceSans,
			Text = "You've been invited to join",
			TextColor3 = Color3.fromRGB(165, 165, 170),
			TextSize = 14,
			TextTransparency = 1,
		}),

		UI.Create("ImageLabel", {
			Name = "ServerIcon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(65, 65, 75),
			BackgroundTransparency = 1,
			ImageTransparency = 1,
			Position = UDim2.new(0.5, 0, 0, 60),
			Size = UDim2.new(0, 80, 0, 80),
			ZIndex = 2,
		}, UDim.new(0, 20)),

		UI.Create("TextLabel", {
			Name = "ServerName",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 129),
			Size = UDim2.new(1, -20, 0, 20),
			Font = Enum.Font.SourceSansBold,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 20,
			TextTransparency = 1,
			TextWrapped = true,
		}),

		UI.Create("TextButton", {
			Name = "Join",
			BackgroundColor3 = Color3.fromRGB(90, 100, 240),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 30, 1, -84),
			Size = UDim2.new(1, -60, 0, 40),
			Font = Enum.Font.SourceSansBold,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 16,
			TextTransparency = 1,
			TextWrapped = true,
		}, UDim.new(0, 5)),

		UI.Create("TextButton", {
			Name = "Ignore",
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, -27, 1, -34),
			Size = UDim2.new(0, 54, 0, 14),
			Font = Enum.Font.SourceSans,
			Text = "No, thanks",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 14,
			TextTransparency = 1,

			UI.Create("Frame", {
				Name = "Line",
				BackgroundColor3 = Color3.fromRGB(220, 220, 220),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 1, 0, 0),
				Visible = false,
			}),
		})
	}, UDim.new(1, 0))

	-- Scripts

	Prompt.Frame.ServerIcon.Image = UI.LoadCustomAsset("https://cdn.discordapp.com/icons/".. inviteData.guild.id.. "/".. inviteData.guild.icon.. ".png")
	Prompt.Frame.ServerName.Text = inviteData.guild.name
	Prompt.Frame.Join.Text = "Join ".. inviteData.guild.name
	Prompt.Frame.Parent = Inviter.Gui

	toggle(Prompt, true)

	local connections = {}

	connections.joinEntered = Prompt.Frame.Join.MouseEnter:Connect(function()
		TS:Create(Prompt.Frame.Join, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(75, 85, 200) }):Play()
	end)

	connections.joinLeft = Prompt.Frame.Join.MouseLeave:Connect(function()
		TS:Create(Prompt.Frame.Join, TweenInfo.new(0.25), { BackgroundColor3 = Color3.fromRGB(90, 100, 240) }):Play()
	end)

	connections.joinClick = Prompt.Frame.Join.Activated:Connect(function()
		task.spawn(Inviter.Join, getCode(invite))

		disconnect(Prompt)
		toggle(Prompt, false)
	end)

	connections.ignoreEntered = Prompt.Frame.Ignore.MouseEnter:Connect(function()
		Prompt.Frame.Ignore.Line.Visible = true
	end)

	connections.ignoreLeft = Prompt.Frame.Ignore.MouseLeave:Connect(function()
		Prompt.Frame.Ignore.Line.Visible = false
	end)

	connections.ignoreClick = Prompt.Frame.Ignore.Activated:Connect(function()
		disconnect(Prompt)
		toggle(Prompt, false)
	end)

	Inviter.Connections[Prompt] = connections
end

return Inviter
