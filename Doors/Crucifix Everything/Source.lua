-- Check
if Vynixu_Crucifix_Everything then return Vynixu_Crucifix_Everything end

-- Functions.lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Variables
local localPlayer = Players.LocalPlayer
local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localRoot = localCharacter:WaitForChild("HumanoidRootPart")
local localPlayerGui = localPlayer:WaitForChild("PlayerGui")
local localMouse = localPlayer:GetMouse()

local assets = {
    Repentance = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/blob/main/Doors/Entity%20Spawner/Assets/Repentance.rbxm?raw=true"),
    Crucifix = LoadCustomInstance("https://github.com/RegularVynixu/Utilities/raw/refs/heads/main/Doors/Item%20Spawner/Assets/Crucifix.rbxm")
}
local moduleScripts = {
	Main_Game = require(localPlayerGui.MainUI.Initiator.Main_Game),
}
getgenv().vynixu_crucifix_manager = {
    Signals = {},
    Crucifixes = {}
}
local module = {}

-- Functions
function WaitUntil(sound, t)
    repeat RunService.RenderStepped:Wait() until sound.TimePosition >= t
end

function FadeOut(pentagram)
    for _, c in pentagram:GetChildren() do
        if c.Name == "BeamFlat" then
            task.delay(c:GetAttribute("Delay"), function()
                TweenService:Create(c, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Brightness = 0 }):Play()
            end)

        elseif c.Name == "BeamChain" then
            TweenService:Create(c, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Brightness = 0 }):Play()
        end
    end
end

function Crucifix(model, playerTool, config)
    -- Handle crucifix uses
    if typeof(config.Uses) == "number" then
        config.Uses -= 1

        if config.Uses <= 0 then
            Destroy(playerTool)
        end
    end

    -- Setup
    local tool = assets.Crucifix:Clone()
    tool:PivotTo(localRoot.CFrame)
    tool.Parent = workspace

	local toolPivot = tool:GetPivot()
	local entityPivot = model:GetPivot()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {localCharacter, model}
	local result = workspace:Raycast(entityPivot.Position, Vector3.new(0, -1000, 0), params)
	
    if not result then
        return
    end

    model:SetAttribute("BeingBanished", true)

    -- Variables
	local repentance = assets.Repentance:Clone()
	local crucifix = repentance.Crucifix
	local pentagram = repentance.Pentagram
	local entityPart = repentance.Entity
	local sound = (config.Resist and crucifix.SoundFail or crucifix.Sound)
	local shaker = moduleScripts.Main_Game.camShaker:StartShake(5, 20, 2, Vector3.new())

    -- Repentance setup
	repentance:PivotTo(CFrame.new(result.Position))
	crucifix.CFrame = toolPivot
	repentance.Entity.CFrame = entityPivot
    crucifix.BodyPosition.Position = (localCharacter:GetPivot() * CFrame.new(0.5, 3, -6)).Position
	repentance.Parent = workspace
	sound:Play()

    -- Teleport model to repentance entity part
	task.spawn(function()
        if not config.Resist then
            while model.Parent and repentance.Parent do
                model:PivotTo(entityPart.CFrame)
                task.wait()
            end

            model:Destroy()
        end
	end)

	-- Pentagram animation
	TweenService:Create(pentagram.Circle, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { CFrame = pentagram.Circle.CFrame - Vector3.new(0, 25, 0) }):Play()
	TweenService:Create(crucifix.BodyAngularVelocity, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { AngularVelocity = Vector3.new(0, 40, 0) }):Play()
	task.delay(2, pentagram.Circle.Destroy, pentagram.Circle)

	task.spawn(function()
        WaitUntil(sound, 2.625)
		
        TweenService:Create(pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 5,
			Range = 40
		}):Play()
		
        TweenService:Create(crucifix.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 11.25,
			Range = 30
		}):Play()
		
        task.wait(1.5)
		
        TweenService:Create(pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()
		
        TweenService:Create(crucifix.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()

		if config.Resist == false then
            TweenService:Create(crucifix.Light, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), { Brightness = 15, Range = 40 }):Play()
            shaker:StartFadeOut(3)
            FadeOut(pentagram)
            TweenService:Create(crucifix.BodyAngularVelocity, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { AngularVelocity = Vector3.new() }):Play()
        end
	end)

	-- Actions
	if config.Resist == false then
		WaitUntil(sound, 2)
		
        TweenService:Create(entityPart, TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { CFrame = repentance.Entity.CFrame - Vector3.new(0, 25, 0) }):Play()
		
        WaitUntil(sound, 6.75)
	else
		WaitUntil(sound, 4)

		TweenService:Create(crucifix.BodyAngularVelocity, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { AngularVelocity = Vector3.new() }):Play()
		TweenService:Create(pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }):Play()
		TweenService:Create(crucifix.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }):Play()
		shaker:StartFadeOut(3)
		task.spawn(function()
			local color = Instance.new("Color3Value")
			color.Value = Color3.fromRGB(137, 207, 255)

			local tween = TweenService:Create(color, TweenInfo.new(0.5, Enum.EasingStyle.Sine), { Value = Color3.fromRGB(255, 116, 130) })
			tween:Play()

			while tween.PlaybackState == Enum.PlaybackState.Playing do
				for _, d in repentance:GetDescendants() do
					if d.ClassName == "Beam" then
						d.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, color.Value), ColorSequenceKeypoint.new(1, color.Value)}

					elseif d.Name == "Crucifix" then
						d.Color = color.Value
					end
				end
				task.wait()
			end
		end)

		WaitUntil(sound, 9.625)
	end

	-- Crucifix explode
	TweenService:Create(repentance.Crucifix, TweenInfo.new(1), { Size = repentance.Crucifix.Size * 3, Transparency = 1 }):Play()
	TweenService:Create(repentance.Pentagram.Base.LightAttach.LightBright, TweenInfo.new(1), { Brightness = 0, Range = 0 }):Play()
	TweenService:Create(repentance.Crucifix.Light, TweenInfo.new(1), { Brightness = 0, Range = 0 }):Play()

	if not config.Resist then
		repentance.Crucifix.ExplodeParticle:Emit(math.random(20, 30))
		moduleScripts.Main_Game.camShaker:ShakeOnce(7.5, 7.5, 0.25, 1.5)
	else
		model:SetAttribute("BeingBanished", false)
		model:SetAttribute("Paused", false)
		FadeOut(pentagram)
	end

	task.delay(5, repentance.Destroy, repentance)
end

function Destroy(playerTool)
    vynixu_crucifix_manager.Crucifixes[playerTool] = nil
    playerTool:Destroy()
end

module.GiveCrucifix = function(config)
    -- Give player crucifix with config
    local crucifix = assets.Crucifix:Clone()

    -- Register crucifix
    vynixu_crucifix_manager.Crucifixes[crucifix] = config

    -- Parent crucifix to backpack
    crucifix.Parent = localPlayer.Backpack
end

-- Main
if vynixu_crucifix_manager.Signals.InputBegan then
    -- Disconnect potential previous signal
    vynixu_crucifix_manager.Signals.InputBegan:Disconnect()
end

-- Create new signal
vynixu_crucifix_manager.Signals.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and localCharacter:FindFirstChild("Crucifix") then
        local playerTool = localCharacter.Crucifix
        local config = vynixu_crucifix_manager.Crucifixes[playerTool]

        -- Validate config
        if not config then
            warn("Could not find Crucifix config for:", playerTool)
            return
        elseif config.EntitiesOnly == true then
            return -- Custom entities only, handled by Entity Spawner module
        end

        -- Get target
        local target = localMouse.Target
        if target then
            local model = target.Parent
            
            -- Validate target
            if model:IsA("Model") and not model:GetAttribute("BeingBanished") and not table.find(config.IgnoreList, model) then
                local isCustomEntity = model:GetAttribute("CustomEntity")

                if config.EntitiesOnly == true and not isCustomEntity then
                    return -- Ignore if not custom entity
                end

                -- Banish whatever
                Crucifix(model, playerTool, config)
            end
        end
    end
end)

warn("Crucifix Everything script : by .vynixu") -- I feel like this is necessary

getgenv().Vynixu_Crucifix_Everything = module
return module
