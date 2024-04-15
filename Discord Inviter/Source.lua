-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local vynixuModules = {
	Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
}
local assets = {
    DiscordInvitePrompt = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/raw/main/Discord%20Inviter/Assets/DiscordInvitePrompt.rbxm")
}
local module = {}

-- Functions
local function getInviteCode(sInvite)
    for i = #sInvite, 1, -1 do
        local char = sInvite:sub(i, i)
        if char == "/" then
            return sInvite:sub(i + 1, #sInvite)
        end
    end
    return sInvite
end

local function getInviteData(sInvite)
    local success, result = pcall(function()
		return HttpService:JSONDecode(request({
            Url = "https://ptb.discord.com/api/invites/".. getInviteCode(sInvite),
            Method = "GET"
        }).Body)
	end)
    if not success then
        warn("Failed to get invite data:\n".. result)
        return
    end
    return success, result
end

local function getInitials(sInvite)
    local initials = sInvite:sub(1, 1)
    for i = 1, #sInvite, 1 do
        local char = sInvite:sub(i, i)
        if char == " " then
            initials ..= sInvite:sub(i + 1, i + 1)
        end
    end
    return initials:sub(1, math.min(#initials, 3))
end

local function make(class, properties)
    local object = Instance.new(class)
    for i, v in properties do
        object[i] = v
    end
    return object
end

local function toggleShowPrompt(promptGui, bool)
    local frame = promptGui.Holder
    local serverIcon = frame.ServerIcon
    local serverInitials = serverIcon.ServerInitials
    local invited = frame.Invited
    local serverName = frame.ServerName
    local accept = frame.Accept
    local ignore = frame.Ignore
    
	if bool then
		frame.Visible = true
		TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0.175, 0, 0.175, 0) }):Play()
		TweenService:Create(frame.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(0, 8) }):Play()
		task.wait(1)
		TweenService:Create(serverIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 0, ImageTransparency = 0 }):Play()
		TweenService:Create(serverInitials, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(0.1)
		TweenService:Create(invited, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(0.1)
		TweenService:Create(serverName, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(0.1)
		TweenService:Create(accept, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
		task.wait(0.1)
		TweenService:Create(ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
		task.wait(1)
	else
		TweenService:Create(ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(accept, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(serverName, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(invited, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(serverIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, ImageTransparency = 1 }):Play()
		TweenService:Create( serverInitials, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
		task.wait(1)
		TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new() }):Play()
		TweenService:Create(frame.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(1, 0) }):Play()
		task.wait(1)
		frame.Visible = false
	end
end

module.Prompt = function(inviteTable)
    local name = inviteTable.name
    local invite = inviteTable.invite

    local success, result = getInviteData(invite)
    if success and result then
        local vanity = getInviteCode(invite)
        
        -- Prompt construction
        local promptGui = asset.DiscordInvitePrompt:Clone()
        if promptGui then
            local holder = promptGui.Holder
            local serverIcon = holder.ServerIcon
            local serverInitials = serverIcon.ServerInitials
            local invited = holder.Invited
            local serverName = holder.ServerName
            local accept = holder.Accept
            local ignore = holder.Ignore

            -- Setup
            holder.Size = UDim2.new()
            holder.UICorner.CornerRadius = UDim.new(1, 0)
            serverName.Text = name
            accept.Text = ("Join <b>%s</b>"):format(name)
            
            if result.guild.icon ~= nil then
                serverIcon.Image = LoadCustomAsset(("https://cdn.discordapp.com/icons/%s/%s.png"):format(result.guild.id, result.guild.icon))
            else
                serverInitials.Text = getInitials(name)
                serverInitials.Visible = true
            end

            for _, c in holder:GetDescendants() do
                if c.ClassName == "TextLabel" or c.ClassName == "TextButton" then
                    c.BackgroundTransparency = 1
                    c.TextTransparency = 1
                elseif c.ClassName == "ImageLabel" then
                    c.ImageTransparency = 1
                end
            end

            -- Display
            promptGui.Parent = CoreGui
            toggleShowPrompt(promptGui, true)

            -- Connections
            local connections = {}
            local function dismiss(join: bool)
                for _, c in connections do
                    c:Disconnect()
                end
                if join then
                    module.Join(invite)
                end
                toggleShowPrompt(promptGui, false)
            end

            connections.acceptEnter = accept.MouseEnter:Connect(function()
                TweenService:Create(accept, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(71, 82, 196) }):Play()
            end)
            connections.acceptLeave = accept.MouseLeave:Connect(function()
                TweenService:Create(accept, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }):Play()
            end)
            connections.acceptActivated = accept.Activated:Connect(function()
                dismiss(true)
            end)
            do
                local text = ignore.Text
                connections.ignoreEnter = ignore.MouseEnter:Connect(function()
                    ignore.Text = ("<u>%s</u>"):format(text)
                end)
                connections.ignoreLeave = ignore.MouseLeave:Connect(function()
                    ignore.Text = text
                end)
                connections.ignoreActivated = ignore.Activated:Connect(function()
                    dismiss(false)
                end)
            end
        end
    end
end

module.Join = function(sInvite)
    local success, result = getInviteData(sInvite)
	if success and result then
		request({
			Url = "http://127.0.0.1:6463/rpc?v=1",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Origin"] = "https://discord.com"
			},
			Body = HttpService:JSONEncode({
				cmd = "INVITE_BROWSER",
				args = {
					code = result.code
				},
				nonce = HttpService:GenerateGUID(false)
			})
		})
	end
end

-- Main
return module
