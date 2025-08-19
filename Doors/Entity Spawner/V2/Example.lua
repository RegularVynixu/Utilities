---====== Load spawner ======---

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/Focuslol666/Utilities/refs/heads/patch-1/Doors/Entity%20Spawner/V2/Source.lua"))()

---====== Create entity ======---

local entity = spawner.Create({
	Entity = {
		Name = "Template Entity",
		Asset = "https://github.com/RegularVynixu/Utilities/raw/main/Doors/Entity%20Spawner/Assets/Entities/Rush.rbxm",
		HeightOffset = 0
	},
	Lights = {
		Flicker = {
			Enabled = true,
			Duration = 1
		},
		Shatter = true,
		Repair = false,
		ColorCorrection = {
		    Enabled = false,
		    Color = Color3.fromRGB(255, 0, 0), -- Color3.new
		    Sound = {
		        SoundId = "rbxassetid://0", -- GetGitSound("URL?raw=true", "Name"),
		        Volume = 1
		    },
		    Duration = 5,
		    FadeIn = 1,
		    FadeOut = 2
		}
	},
	Earthquake = {
		Enabled = true
	},
	CameraShake = {
		Enabled = true,
		Range = 100,
		Values = {1.5, 20, 0.1, 1} -- Magnitude, Roughness, FadeIn, FadeOut
	},
	Movement = {
		Speed = 100,
		Delay = 2,
		Reversed = false
	},
	Rebounding = {
		Enabled = true,
		Type = "Ambush", -- "Blitz"
		Min = 1,
		Max = 1,
		Delay = 2
	},
	Damage = {
		Enabled = true,
		Range = 40,
		Amount = 125
	},
	Jumpscare = {
	    Enabled = false,
	    Face = "rbxassetid://0",
	    FacePosition = UDim2.new(0.5, 0, 0.5, 0),
	    FaceSize = UDim2.new(0, 150, 0, 150),
	    BackgroundColor = Color3.new(1, 1, 1), -- Color3.fromRGB
	    BackgroundColor2 = Color3.new(0, 0, 0), -- Color3.fromRGB
	    Sound = "rbxassetid://0", -- GetGitSound("URL?raw=true", "Name"),
	    SoundVolume = 5
	},
	Achievements = {
	    Survive = {
	        Enabled = true,
	        Once = false,
	        Title = "Survive Title",
	        Desc = "Survive Description",
	        Reason = "Survive Reason",
	        Image = "rbxassetid://12309073114"
	    },
	    Crucifix = {
	        Enabled = true,
	        Once = true,
	        Title = "Crucifix Title",
	        Desc = "Crucifix Description",
	        Reason = "Crucifix Reason",
	        Image = "rbxassetid://12309073114"
	    },
	    Death = {
	        Enabled = false,
	        Once = false,
	        Title = "Death Title",
	        Desc = "Death Description",
	        Reason = "Death Reason",
	        Image = "rbxassetid://12309073114"
	    }
	},
	Crucifixion = {
	    Type = "Guiding", -- "Curious"
		Enabled = true,
		Range = 40,
		Resist = false,
		Break = true
	},
	Death = {
		Type = "Guiding", -- "Curious"
		Hints = {"Death", "Hints", "Go", "Here"},
		Cause = ""
	}
})

---====== Debug entity ======---

entity:SetCallback("OnSpawned", function()
    print("Entity has spawned")
end)

entity:SetCallback("OnStartMoving", function()
    print("Entity has started moving")
end)

entity:SetCallback("OnEnterRoom", function(room, firstTime)
    if firstTime == true then
        print("Entity has entered room: ".. room.Name.. " for the first time")
    else
        print("Entity has entered room: ".. room.Name.. " again")
    end
end)

entity:SetCallback("OnLookAt", function(lineOfSight)
	if lineOfSight == true then
		print("Player is looking at entity")
	else
		print("Player view is obstructed by something")
	end
end)

entity:SetCallback("OnRebounding", function(startOfRebound)
    if startOfRebound == true then
        print("Entity has started rebounding")
	else
        print("Entity has finished rebounding")
	end
end)

entity:SetCallback("OnDespawning", function()
    print("Entity is despawning")
end)

entity:SetCallback("OnDespawned", function()
    print("Entity has despawned")
end)

entity:SetCallback("OnDamagePlayer", function(newHealth)
	if newHealth == 0 then
		print("Entity has killed the player")
	else
		print("Entity has damaged the player")
	end
end)

--[[

DEVELOPER NOTE:
By overwriting 'CrucifixionOverwrite' the default crucifixion callback will be replaced with your custom callback.

entity:SetCallback("CrucifixionOverwrite", function()
    print("Custom crucifixion callback")
end)

]]--

---====== Run entity ======---

entity:Run()
