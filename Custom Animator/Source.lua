-- Services

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")

local ActiveAnimations = {}
local CustomAnimator = {}

local IsPlayingAnimation = false

-- Misc Functions

function playAnimation(self)
    task.spawn(function()
        -- Registry

        if ActiveAnimations[self.Model] then
            stopAnimation(self)
        end

        ActiveAnimations[self.Model] = {
            StartTick = tick(),
            Motors = {},
            Tweens = {}
        }

        local activeAnimations = ActiveAnimations[self.Model]
        local startTick = activeAnimations.StartTick

        for _, desc in next, self.Model:GetDescendants() do
            if desc:IsA("BasePart") and desc:FindFirstChildOfClass("Motor6D") then
                local motor = desc:FindFirstChildOfClass("Motor6D")

                table.insert(activeAnimations.Motors, {
                    Limb = desc,
                    Motor = motor,
                    Properties = { C0 = motor.C0 }
                })

            elseif desc.ClassName == "Humanoid" or desc.ClassName == "AnimationController" then
                for _, animTrack in next, desc:GetPlayingAnimationTracks() do
                    animTrack:Stop()
                end
            end
        end

        -- Obtain keyframes

        local keyframes = {}

        for _, keyframe in next, self.KeyframeSequence:GetChildren() do
            if keyframe.ClassName == "Keyframe" then
                table.insert(keyframes, keyframe)
            end
        end

        table.sort(keyframes, function(a, b)
            return a.Time < b.Time
        end)

        -- Play animation

        for _ = 1, (self.KeyframeSequence.Loop and 9e9 or 1) do
            IsPlayingAnimation = true

            if startTick ~= activeAnimations.StartTick then
                break
            end

            for _, motor in next, activeAnimations.Motors do
                if startTick ~= activeAnimations.StartTick then
                    break
                end

                task.spawn(function()
                    local poses = {}
    
                    for keyframeIdx, keyframe in next, keyframes do
                        if startTick ~= activeAnimations.StartTick then
                            break
                        end

                        for _, pose in next, keyframe:GetDescendants() do
                            if pose.ClassName == "Pose" and pose.Name == motor.Limb.Name then
                                local prevKeyframe = nil
    
                                for i, v in next, keyframes do
                                    if i < keyframeIdx then
                                        for i2, v2 in next, v:GetDescendants() do
                                            if v2.ClassName == "Pose" and v2.Name == motor.Limb.Name then
                                                prevKeyframe = keyframes[i]
    
                                                break
                                            end
                                        end
                                    end
                                end
    
                                table.insert(poses, {
                                    Pose = pose,
                                    Style = Enum.EasingStyle[pose.EasingStyle.Name],
                                    Direction = Enum.EasingDirection[pose.EasingDirection.Name],
                                    Duration = prevKeyframe and (keyframe.Time - prevKeyframe.Time) / self.Speed or 0.05
                                })
    
                                break
                            end
                        end
                    end
    
                    for _, pose in next, poses do
                        if startTick ~= activeAnimations.StartTick then
                            break
                        end

                        local tween = TS:Create(motor.Motor, TweenInfo.new(pose.Duration, pose.Style, pose.Direction), {C0 = motor.Properties.C0 * pose.Pose.CFrame})
                        table.insert(activeAnimations.Tweens, tween)
                        tween:Play()
    
                        task.wait(pose.Duration)
                    end
                end)
            end

            local totalDuration = 0

            for keyframeIdx, keyframe in next, keyframes do
                local prevKeyframe = keyframes[keyframeIdx - 1]
                local duration = prevKeyframe and (keyframe.Time - prevKeyframe.Time) / self.Speed or 0.05
                totalDuration += duration
            end

            task.wait(totalDuration + 0.1)

            if startTick == activeAnimations.StartTick then
                stopAnimation(self, true)
            end
        end

        IsPlayingAnimation = false
    end)
end

function stopAnimation(self, bool)
    local activeAnimations = ActiveAnimations[self.Model]

    if activeAnimations then
        for _, motor in next, activeAnimations.Motors do
            motor.Motor.C0 = motor.Properties.C0
        end

        for _, tween in next, activeAnimations.Tweens do
            tween:Cancel()
        end

        if not bool then
            activeAnimations.StartTick = nil
            ActiveAnimations[self.Model] = nil
        end
    end

    IsPlayingAnimation = false
end

function adjustSpeed(self, speed)
    self.Speed = speed
end

-- Functions

CustomAnimator.LoadAnimation = function(model, keyframeSequence)
    return {
        Model = model,
        KeyframeSequence = keyframeSequence,
        Play = playAnimation,
        Stop = stopAnimation,
        AdjustSpeed = adjustSpeed,
        Speed = 1
    }
end

-- Scripts

local ncall; ncall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if not checkcaller() and getnamecallmethod() == "Play" and self.ClassName == "AnimationTrack" and IsPlayingAnimation then
        return
    end
    
    return ncall(self, ...)
end))

local nidx; nidx = hookmetamethod(game, "__newindex", newcclosure(function(t, k, v)
    if not checkcaller() and (k == "C0" or k == "C1") and IsPlayingAnimation then
        return
    end
    
    return nidx(t, k, v)
end))

Plr.CharacterAdded:Connect(function()
    IsPlayingAnimation = false
end)

return CustomAnimator
