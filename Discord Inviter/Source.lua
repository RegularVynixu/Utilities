-- Services

local HS = game:GetService("HttpService")
local TS = game:GetService("TweenService")

-- Variables

local Exploit = {
    Request = (syn and syn.request) or request or http_request,
}

local Utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Utils.lua"))()

local Inviter = {
    Connections = {}
}

-- Misc Functions

local function getCodeFromInvite(invite)
    if string.find(invite, "/") then
        for i = 1, #invite do
            local newIdx = #invite - i

            if string.sub(invite, newIdx, newIdx) == "/" then
                return string.sub(invite, newIdx + 1, #invite)
            end
        end
    end

    return invite
end

local function togglePrompt(bool)
    if not Inviter.Prompt then
        return
    end

    if bool then
        Inviter.Background.Visible = true
        Inviter.Background.Size = UDim2.new(0, 0, 0, 0)
        Inviter.Background.UICorner.CornerRadius = UDim.new(1, 0)

        TS:Create(Inviter.Background, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(1, 0, 1, 0) }):Play()
        TS:Create(Inviter.Background.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(0, 7) }):Play()
        task.wait(1)
        TS:Create(Inviter.ServerIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 0, ImageTransparency = 0 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.Background.Invited, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.ServerName, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.Join, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.Ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 0 }):Play()
        task.wait(1)
    else
        TS:Create(Inviter.Ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.Join, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.ServerName, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.Background.Invited, TweenInfo.new(1, Enum.EasingStyle.Quint), { TextTransparency = 1 }):Play()
        task.wait(0.1)
        TS:Create(Inviter.ServerIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), { BackgroundTransparency = 1, ImageTransparency = 1 }):Play()
        task.wait(1)
        TS:Create(Inviter.Background, TweenInfo.new(1, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 0, 0, 0) }):Play()
        TS:Create(Inviter.Background.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), { CornerRadius = UDim.new(1, 0) }):Play()
        task.wait(1)
    end
end

local function disconnect()
    for i, v in next, Inviter.Connections do
        v:Disconnect()
        v = nil
    end

    Inviter.Ignore.Line.Visible = false
end

local function destroy()
    if not Inviter.Prompt then
        return
    end

    disconnect()
    Inviter.Prompt:Destroy()
    Inviter.Prompt = nil
end

-- Functions

Inviter.Prompt = function(data)
    assert(data.invite, "Improper or no invite data assigned")
    assert(Exploit.Request, "Executor missing function : 'request'")

    local inviteCode = getCodeFromInvite(data.invite)

    -- UI Construction

    Inviter.Prompt = Utils.Create("ScreenGui", {
        Name = "Invite Prompt - ".. inviteCode,
        Enabled = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

        Utils.Create("Frame", {
            Name = "Holder",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 300),
        }),
    })

    Inviter.Background = Utils.Create("Frame", {
        Name = "Background",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(55, 55, 65),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),

        Utils.Create("TextLabel", {
            Name = "Invited",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 110),
            Size = UDim2.new(1, -20, 0, 14),
            Font = Enum.Font.SourceSans,
            Text = "You've been invited to join",
            TextColor3 = Color3.fromRGB(165, 165, 170),
            TextSize = 14,
            TextTransparency = 1,
        }),
    }, UDim.new(1, 0))

    Inviter.ServerName = Utils.Create("TextLabel", {
        Name = "Name",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 129),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.SourceSansBold,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextTransparency = 1,
        TextWrapped = true,
    })

    Inviter.ServerIcon = Utils.Create("ImageLabel", {
        Name = "Icon",
        Parent = Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(65, 65, 75),
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 60),
        Size = UDim2.new(0, 80, 0, 80),
        ZIndex = 2,
    }, UDim.new(0, 20))

    Inviter.Join = Utils.Create("TextButton", {
        Name = "Join",
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(90, 100, 240),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 30, 1, -84),
        Size = UDim2.new(1, -60, 0, 40),
        Font = Enum.Font.SourceSansBold,
        Text = "Join",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextTransparency = 1,
        TextWrapped = true,
    }, UDim.new(0, 5))

    Inviter.Ignore = Utils.Create("TextButton", {
        Name = "Ignore",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -27, 1, -34),
        Size = UDim2.new(0, 54, 0, 14),
        Font = Enum.Font.SourceSans,
        Text = "No, thanks",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 14,
        TextTransparency = 1,

        Utils.Create("Frame", {
            Name = "Line",
            BackgroundColor3 = Color3.fromRGB(220, 220, 220),
            BorderSizePixel = 0,
            Position = UDim2.new(0, -1, 1, 0),
            Size = UDim2.new(1, 1, 0, 1),
            Visible = false,
        }),
    })

    -- Scripts

    local inviteData = HS:JSONDecode(Exploit.Request({
        Url = "https://ptb.discord.com/api/invites/".. inviteCode,
        Method = "GET",
    }).Body)

    if not inviteData then
        warn("['".. inviteCode.. "'] Something went wrong while getting invite data")
        destroy()
        return
    end

    Inviter.Prompt.Parent = game.CoreGui
    Inviter.Background.Parent = Inviter.Prompt.Holder
    Inviter.ServerName.Parent = Inviter.Background
    Inviter.ServerIcon.Parent = Inviter.Background
    Inviter.Join.Parent = Inviter.Background
    Inviter.Ignore.Parent = Inviter.Background

    Inviter.ServerName.Text = data.name or inviteData.guild.name
    Inviter.ServerIcon.Image = Utils.LoadCustomAsset("https://cdn.discordapp.com/icons/".. inviteData.guild.id.. "/".. inviteData.guild.icon.. ".png")
    Inviter.Join.Text = "Join ".. (data.name or inviteData.guild.name)

    Inviter.Prompt.Enabled = true
    togglePrompt(true)
    disconnect()

    Inviter.Connections.JoinEntered = Inviter.Join.MouseEnter:Connect(function()
        TS:Create(Inviter.Join, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(75, 85, 200),
        }):Play()
    end)

    Inviter.Connections.JoinLeft = Inviter.Join.MouseLeave:Connect(function()
        TS:Create(Inviter.Join, TweenInfo.new(0.25), {
            BackgroundColor3 = Color3.fromRGB(90, 100, 240),
        }):Play()
    end)

    Inviter.Connections.IgnoreEntered = Inviter.Ignore.MouseEnter:Connect(function()
        Inviter.Ignore.Line.Visible = true
    end)

    Inviter.Connections.IgnoreLeft = Inviter.Ignore.MouseLeave:Connect(function()
        Inviter.Ignore.Line.Visible = false
    end)

    Inviter.Connections.JoinClick = Inviter.Join.MouseButton1Click:Connect(function()
        disconnect()
        togglePrompt(false)
        destroy()
        
        Inviter.Join(data.invite)
    end)

    Inviter.Connections.IgnoreClick = Inviter.Ignore.MouseButton1Click:Connect(function()
        disconnect()
        togglePrompt(false)
        destroy()
    end)
end

Inviter.Join = function(invite)
    assert(Exploit.Request, "Executor missing function : 'request'")

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
                code = getCodeFromInvite(invite)
            },
            nonce = HS:GenerateGUID(false)
        })
    })
end

-- Scripts

return Inviter
