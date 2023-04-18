--[[ Services ]]--

local tweenService = game:GetService("TweenService");

--[[ Variables ]]--

local animator = {};
local storedMotors = {};
local isPlayingAnimation = false;

--[[ Functions ]]--

local function getKeyframesWithPose(keyframeSequence, pose)
	local keyframes = {};
	local current;
	local children = keyframeSequence:GetChildren();
	for i = 1, #children do
		local keyframe = children[i];
		if keyframe.ClassName == "Keyframe" then
			if keyframe:FindFirstChild(pose.Name, true) then
				keyframes[#keyframes + 1] = keyframe;
			end
			if pose:IsDescendantOf(keyframe) then
				current = keyframe;
			end
		end
	end
	table.sort(keyframes, function(a, b)
		return a.Time < b.Time;
	end);	
	return keyframes, table.find(keyframes, current);
end;

local function findFirstDescendantOfClass(obj, class)
	local descendants = obj:GetDescendants();
	for i = 1, #descendants do
		local desc = descendants[i];
		if desc.ClassName == class then
			return desc;
		end
	end
end;

animator.playAnimation = function(model, keyframeSequence, speed)
	speed = speed or 1;
	local poses = {};
	local descendants = keyframeSequence:GetDescendants();
	for i = 1, #descendants do
		local pose = descendants[i];
		if pose.ClassName == "Pose" then
			local part = model:FindFirstChild(pose.Name, true);
			if part then
				local motor = findFirstDescendantOfClass(part, "Motor6D");
				if motor then
					storedMotors[motor.Name] = storedMotors[motor.Name] or motor.C0;
					
					local keyframes, index = getKeyframesWithPose(keyframeSequence, pose);
					local frame = keyframes[index];
					local prevFrame = keyframes[index - 1];
					local nextFrame = keyframes[index + 1];
					
					poses[#poses + 1] = {
						time = frame.Time;
						duration = prevFrame and frame.Time - prevFrame.Time or nextFrame and nextFrame.Time - frame.Time or 0;
						style = Enum.EasingStyle[pose.EasingStyle.Name];
						direction = Enum.EasingDirection[pose.EasingDirection.Name];
						value = storedMotors[motor.Name] * pose.CFrame;
						motor = motor;
					};
				end
			end
		end
	end
	
	local humanoid = model:FindFirstChild("Humanoid", true);
	if humanoid then
		local anims = humanoid:GetPlayingAnimationTracks();
		if #anims > 0 then
			for i = 1, #anims do
				anims[i]:Stop();
			end
		end
	end
	
	for _ = 1, keyframeSequence.Loop and 9e9 or 1, 1 do
		isPlayingAnimation = true;
		local passers = 0;
		for i = 1, #poses do
			local pose = poses[i];
			passers += 1;
			task.delay(pose.time, function()
				local tween = tweenService:Create(pose.motor, TweenInfo.new(pose.duration / speed, pose.style, pose.direction), {C0 = pose.value});
				tween:Play();
				tween.Completed:Wait();				
				passers -= 1;
			end);
		end
		repeat task.wait() until passers <= 0;
		isPlayingAnimation = false;
	end
end;

--[[Main]]--

local namecall; namecall = hookmetamethod(game, "__namecall", function(self, ...)
	if not checkcaller() and getnamecallmethod() == "Play" and self.ClassName == "AnimationTrack" and isPlayingAnimation then
		return;
	end
	return namecall(self, ...);
end)
local newindex; newindex = hookmetamethod(game, "__newindex", function(t, k, v)
	if not checkcaller() and (k == "C0" or k == "C1") and isPlayingAnimation then
		return;
	end
	return newindex(t, k, v);
end)

return animator;
