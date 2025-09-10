---====== Load spawner ======---

local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/Focuslol666/Utilities/refs/heads/patch-1/Doors/Entity%20Spawner/V2/Source.lua"))()

---====== Create entity ======---

local entity = spawner.Create({
	Entity = {
		Name = "Blitz Example",
		Asset = "https://github.com/RegularVynixu/Utilities/raw/main/Doors/Entity%20Spawner/Assets/Entities/BackdoorRush.rbxm",
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
		    Color = Color3.fromRGB(255, 0, 0),
		    CameraShake = {10, 5, 2, 5},
		    Sound = {
		        SoundId = "rbxassetid://0",
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
		Values = {1.5, 20, 0.1, 1}
	},
	Movement = {
		Speed = 100,
		Delay = 2,
		Reversed = false
	},
	Rebounding = {
		Enabled = true,
		Type = "Blitz",
		Min = 1,
		Max = math.random(1, 2),
		Delay = math.random(10, 30) / 10
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
	    BackgroundColor = Color3.new(1, 1, 1),
	    BackgroundColor2 = Color3.new(0, 0, 0),
	    Sound = "rbxassetid://0",
	    SoundVolume = 5
	},
	Achievements = {
	    Survive = {
	        Enabled = true,
	        Once = false,
	        Title = "Survive Title",
	        Desc = "Survive Description",
	        Reason = "Survive Reason",
	        Image = "rbxassetid://12309073114",
	        Prize = {
                Revives = {
                    Visible = false,
                    Amount = 1
                },
                Knobs = {
                    Visible = false,
                    Amount = 100
                },
                Stardust = {
                    Visible = false,
                    Amount = 20
                }
            }
	    },
	    Crucifix = {
	        Enabled = true,
	        Once = true,
	        Title = "Crucifix Title",
	        Desc = "Crucifix Description",
	        Reason = "Crucifix Reason",
	        Image = "rbxassetid://12309073114",
	        Prize = {
                Revives = {
                    Visible = false,
                    Amount = 1
                },
                Knobs = {
                    Visible = false,
                    Amount = 100
                },
                Stardust = {
                    Visible = true,
                    Amount = 20
                }
            }
	    },
	    Death = {
	        Enabled = false,
	        Once = false,
	        Title = "Death Title",
	        Desc = "Death Description",
	        Reason = "Death Reason",
	        Image = "rbxassetid://12309073114",
	        Prize = {
                Revives = {
                    Visible = false,
                    Amount = 1
                },
                Knobs = {
                    Visible = false,
                    Amount = 100
                },
                Stardust = {
                    Visible = false,
                    Amount = 20
                }
            }
	    }
	},
	Crucifixion = {
	    Type = "Curious",
		Enabled = true,
		Range = 40,
		Resist = false,
		Break = true
	},
	Death = {
	    IsolationFloors = true,
		Type = "Guiding", -- "Curious"
		Hints = {"Death", "Hints", "Go", "Here"}, -- *Required!
        Cause = "",
        Floors = {
            Hotel = {
                Type = "Guiding", -- "Curious"
		        Hints = {"You died to Blitz.", "It looks like Rush, but it may rebounds.", "Please pay attention to the flicker lights and hide as soon as possible.", "Good luck!"},
                Cause = ""
            },
            Mines = {
                Type = "Guiding", -- "Curious"
		        Hints = {"You died to Blitz.", "It looks like Rush, but it may rebounds.", "Please pay attention to the flicker lights and hide as soon as possible.", "Good luck!"},
                Cause = ""
            }
        },
        Subfloors = {
            Backdoor = {
                Type = "Curious", -- "Guiding"
		        Hints = {"Oh... Hello.", "I didn't expect to see you here.", "Let's see what you died to.", "Oh, one of my favorites.", "She said we should call that one Blitz.", "Well... I'll see you later, right? You'll come back?", "Haha... of course you will."},
                Cause = ""
            },
            Rooms = {
                Type = "Curious", -- "Guiding"
		        Hints = {"Oh... Hello.", "I didn't expect to see you here.", "Let's see what you died to.", "Oh, one of my favorites.", "She said we should call that one Blitz.", "Well... I'll see you later, right? You'll come back?", "Haha... of course you will."},
                Cause = ""
            },
            Outdoors = {
                Type = "Curious", -- "Guiding"
		        Hints = {"Oh... Hello.", "I didn't expect to see you here.", "Let's see what you died to.", "Oh, one of my favorites.", "She said we should call that one Blitz.", "Well... I'll see you later, right? You'll come back?", "Haha... of course you will."},
                Cause = ""
            }
        }
	}
})

---====== Debug entity ======---

local entityModel = entity.Model
local main = entityModel:WaitForChild("Main")

local attachment = main:WaitForChild("Attachment")
local AttachmentSwitch = main:WaitForChild("AttachmentSwitch")

local ogState = attachment:WaitForChild("ParticleEmitter").Enabled
    local ogSwitchState = AttachmentSwitch:WaitForChild("ParticleEmitter").Enabled

entity:SetCallback("OnRebounding", function(startOfRebound)
	-- Variables for the entity
	local sounds = {
		footsteps = main:WaitForChild("Footsteps"),
		playSound = main:WaitForChild("PlaySound"),
		switch = main:WaitForChild("Switch"),
		switchBack = main:WaitForChild("SwitchBack")
	}

	-- Toggle particle emitters and lights within the entityModel
	-- To switch between green & red state
	for _, c in attachment:GetChildren() do
		c.Enabled = (not startOfRebound)
	end
	for _, c in AttachmentSwitch:GetChildren() do
		c.Enabled = startOfRebound
	end

	-- Play sounds
	if startOfRebound == true then
		sounds.footsteps.PlaybackSpeed = 0.35
		sounds.playSound.PlaybackSpeed = 0.25
		sounds.switch:Play()
	else
		sounds.footsteps.PlaybackSpeed = 0.25
		sounds.playSound.PlaybackSpeed = 0.16
		sounds.switchBack:Play()
	end
end)

entity:SetCallback("OnCrucified", function()
	local hasTool, tool = PlayerHasItemEquipped("Crucifix")
	if hasTool and tool and not entityModel:GetAttribute("BeingBanished") then
		entityModel:SetAttribute("Paused", true)
		CrucifixEntity(entity, tool)
	end

    local function Particle(attach, bool)
        for _, c in attach:GetChildren() do
            if not c.Enabled then
		        c.Enabled = bool
		    end
	    end
    end

    if entity.Crucifixion.Resist then
        Particle(attachment, true)
        Particle(AttachmentSwitch, true)
	    task.wait(9.625)
	    Particle(attachment, ogState)
	    Particle(AttachmentSwitch, ogSwitchState)
	else
	    Particle(attachment, true)
        Particle(AttachmentSwitch, true)
	end
end)

---====== Run entity ======---

entity:Run()