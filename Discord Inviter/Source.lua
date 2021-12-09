--[[
     _____  _                       _   _____            _ _            
    |  __ \(_)                     | | |_   _|          (_) |           
    | |  | |_ ___  ___ ___  _ __ __| |   | |  _ ____   ___| |_ ___ _ __ 
    | |  | | / __|/ __/ _ \| '__/ _` |   | | | '_ \ \ / / | __/ _ \ '__|
    | |__| | \__ \ (_| (_) | | | (_| |  _| |_| | | \ V /| | ||  __/ |   
    |_____/|_|___/\___\___/|_|  \__,_| |_____|_| |_|\_/ |_|\__\___|_|   
    
    
    Discord Inviter v1.0.2b
    
    UI - Vynixu (Inspired by Discord)
    Scripting - Vynixu

    Documentation : 

    [ What's new? ]

    [+] Rewritten (now open source)
    [+] Slightly different UI
    [+] Server icon- and name are now automatically applied
    
]]--

-- Services

local HS = game:GetService("HttpService")
local TS = game:GetService("TweenService")

-- Exploit

local Exploit = {
    request = (syn and syn.request) or request or http_request,
    getasset = getsynasset or getcustomasset,
}

-- Utility

local Utility = {}

function Utility:Create(class, properties, radius)
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

function Utility:GetCodeFromInvite(invite)
    if invite:find("/") then
        for i = 1, #invite do
            local newIdx = #invite - i
            if invite:sub(newIdx, newIdx) == "/" then
                return invite:sub(newIdx + 1, #invite)
            end
        end
    end
    return invite
end

function Utility:GetCustomAsset(url)
    if url == "null" then
        return ""
    end
    if Exploit.request and Exploit.getasset then
        local data = Exploit.request({
            Url = url,
            Method = "GET",
        }).Body

        local fileName = "custom_asset[#".. math.random(1, 99999).. "].png"
        writefile(fileName, data)
        for i = 1, 100 do -- 100 attempts to get the file
            if isfile(fileName) then
                break
            end
            task.wait()
        end
        if not isfile(fileName) then
            return ""
        end

        task.spawn(function()
            task.wait(5)
            if isfile(fileName) then
                delfile(fileName)
            end
        end)        
        return Exploit.getasset(fileName)
    end
    return ""
end

-- Inviter

local Inviter = {
    Current = {
        Connections = {},
    },
}

-- Misc Functions

function TogglePrompt(bool)
    assert(Inviter.Current.Prompt, "No invite is currently prompting.")

    if bool then
        Inviter.Current.Background.Visible = true
        Inviter.Current.Background.Size = UDim2.new(0, 0, 0, 0)
        Inviter.Current.Background.UICorner.CornerRadius = UDim.new(1, 0)

        TS:Create(Inviter.Current.Background, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 1, 0),
        }):Play()
        TS:Create(Inviter.Current.Background.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            CornerRadius = UDim.new(0, 7),
        }):Play()
        task.wait(1)

		TS:Create(Inviter.Current.ServerIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0,
            ImageTransparency = 0,
        }):Play()
        task.wait(.1)
		TS:Create(Inviter.Current.Background.Invited, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            TextTransparency = 0,
        }):Play()
        task.wait(.1)
		TS:Create(Inviter.Current.ServerName, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            TextTransparency = 0,
        }):Play()
        task.wait(.1)
		TS:Create(Inviter.Current.Join, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0,
            TextTransparency = 0,
        }):Play()
        task.wait(.1)
		TS:Create(Inviter.Current.Ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            TextTransparency = 0,
        }):Play()
		wait(1)
    else
        TS:Create(Inviter.Current.Ignore, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            TextTransparency = 1,
        }):Play()
		wait(.1)
        TS:Create(Inviter.Current.Join, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1,
            TextTransparency = 1,
        }):Play()
        task.wait(.1)
        TS:Create(Inviter.Current.ServerName, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            TextTransparency = 1,
        }):Play()
        task.wait(.1)
        TS:Create(Inviter.Current.Background.Invited, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            TextTransparency = 1,
        }):Play()
        task.wait(.1)
        TS:Create(Inviter.Current.ServerIcon, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1,
            ImageTransparency = 1,
        }):Play()
        task.wait(1)

        TS:Create(Inviter.Current.Background, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        TS:Create(Inviter.Current.Background.UICorner, TweenInfo.new(1, Enum.EasingStyle.Quint), {
            CornerRadius = UDim.new(1, 0),
        }):Play()
        task.wait(1)
        
        Inviter.Destroy()
    end
end

-- Functions

Inviter.Prompt = function(data)
    assert(not Inviter.Current.Prompt, "Already prompting an invite.")
    assert(data.invite, "Improper or no invite data assigned.")
    assert(Exploit.request, "Executor missing function : 'request'")

    data.invite = Utility:GetCodeFromInvite(data.invite)

    -- UI Construction

    Inviter.Current.Prompt = Utility:Create("ScreenGui", {
        Name = "Prompt - ".. data.invite,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

        Utility:Create("Frame", {
            Name = "Holder",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 300),
        }),
    })

    Inviter.Current.Background = Utility:Create("Frame", {
        Name = "Background",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(55, 55, 65),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),

        Utility:Create("TextLabel", {
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

    Inviter.Current.ServerName = Utility:Create("TextLabel", {
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

    Inviter.Current.ServerIcon = Utility:Create("ImageLabel", {
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

    Inviter.Current.Join = Utility:Create("TextButton", {
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

    Inviter.Current.Ignore = Utility:Create("TextButton", {
        Name = "Ignore",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -27, 1, -34),
        Size = UDim2.new(0, 54, 0, 14),
        Font = Enum.Font.SourceSans,
        Text = "No, thanks",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 14,
        TextTransparency = 1,

        Utility:Create("Frame", {
            Name = "Line",
            BackgroundColor3 = Color3.fromRGB(220, 220, 220),
            BorderSizePixel = 0,
            Position = UDim2.new(0, -1, 1, 0),
            Size = UDim2.new(1, 1, 0, 1),
            Visible = false,
        }),
    })

    -- Scripts

    local InviteData = HS:JSONDecode(Exploit.request({
        Url = "https://ptb.discord.com/api/invites/".. data.invite,
        Method = "GET",
    }).Body)
    if not InviteData then
        warn("[".. data.invite.. "] Something went wrong while attempting to get the invite data.")
        Inviter.Destroy()
        return
    end
    local guildAssets = {
        Icon = Utility:GetCustomAsset("https://cdn.discordapp.com/icons/".. InviteData.guild.id.. "/".. InviteData.guild.icon.. ".png"),
    }

    Inviter.Current.Prompt.Parent = game.CoreGui
    Inviter.Current.Background.Parent = Inviter.Current.Prompt.Holder
    Inviter.Current.ServerName.Parent = Inviter.Current.Background
    Inviter.Current.ServerIcon.Parent = Inviter.Current.Background
    Inviter.Current.Join.Parent = Inviter.Current.Background
    Inviter.Current.Ignore.Parent = Inviter.Current.Background

    Inviter.Current.ServerName.Text = data.name or InviteData.guild.name
    Inviter.Current.ServerIcon.Image = guildAssets.Icon
    Inviter.Current.Join.Text = "Join ".. data.name or InviteData.guild.name

    TogglePrompt(true)
    Inviter.Disconnect()    
    Inviter.Current.Connections.JoinEntered = Inviter.Current.Join.MouseEnter:Connect(function()
        TS:Create(Inviter.Current.Join, TweenInfo.new(.25), {
            BackgroundColor3 = Color3.fromRGB(75, 85, 200),
        }):Play()
    end)

    Inviter.Current.Connections.JoinLeft = Inviter.Current.Join.MouseLeave:Connect(function()
        TS:Create(Inviter.Current.Join, TweenInfo.new(.25), {
            BackgroundColor3 = Color3.fromRGB(90, 100, 240),
        }):Play()
    end)

    Inviter.Current.Connections.IgnoreEntered = Inviter.Current.Ignore.MouseEnter:Connect(function()
        Inviter.Current.Ignore.Line.Visible = true
    end)

    Inviter.Current.Connections.IgnoreLeft = Inviter.Current.Ignore.MouseLeave:Connect(function()
        Inviter.Current.Ignore.Line.Visible = false
    end)

    Inviter.Current.Connections.JoinClick = Inviter.Current.Join.MouseButton1Click:Connect(function()
        Inviter.Disconnect()
        Inviter.Join(data.invite)
        TogglePrompt(false)
    end)

    Inviter.Current.Connections.IgnoreClick = Inviter.Current.Ignore.MouseButton1Click:Connect(function()
        Inviter.Disconnect()
        TogglePrompt(false)
    end)
end

Inviter.Join = function(invite)
    assert(Exploit.request, "Executor missing function : 'request'")
    Exploit.request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        Body = HS:JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {
                code = invite,
            },
            nonce = HS:GenerateGUID(false)
        }),
    })
end

Inviter.Disconnect = function()
    for i, v in next, Inviter.Current.Connections do
        v:Disconnect()
        v = nil
    end
    Inviter.Current.Ignore.Line.Visible = false
end

Inviter.Destroy = function()
    assert(Inviter.Current.Prompt, "No invite is currently prompting.")
    Inviter.Disconnect()
    Inviter.Current.Prompt:Destroy()
end

-- Scripts

return Inviter
