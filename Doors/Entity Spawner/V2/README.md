## Contents
- **[Fixed](https://github.com/Focuslol666/Utilities/tree/patch-1/Doors/Entity%20Spawner/V2#fixed)**
    - Main
    - Path Error Fixed
    - Crucifixion Bug Fixed
---
- **[Assets](https://github.com/Focuslol666/Utilities/tree/patch-1/Doors/Entity%20Spawner/V2#assets)**
    - Entity Spawner Source
    - Entity Spawner Example
    - Blitz Spawner Example
    - Entity Repentance
    - Crucifix
---
- **[Modified](https://github.com/Focuslol666/Utilities/tree/patch-1/Doors/Entity%20Spawner/V2#modified)**
    - [Coming Soon](https://github.com/Focuslol666/Utilities/tree/patch-1/Doors/Entity%20Spawner/V2#coming-soon)
    - [Released](https://github.com/Focuslol666/Utilities/tree/patch-1/Doors/Entity%20Spawner/V2#released)
    - [Removed](https://github.com/Focuslol666/Utilities/tree/patch-1/Doors/Entity%20Spawner/V2#removed)
## Fixed
- **Vynixu's Entity Spawner V2** was unusable because of **The Great Outdoors Update**, and I fixed it.
    - **Path Error Fixed**: `ClientModules` folder name changed to `ModulesClient`.
    - **Crucifixion Bug Fixed**: Entity are also removed when `Resist` is enabled.
## Assets
- **[Entity Spawner Source](https://github.com/Focuslol666/Utilities/blob/patch-1/Doors/Entity%20Spawner/V2/Source.lua)**
- **[Entity Spawner Example](https://github.com/Focuslol666/Utilities/blob/patch-1/Doors/Entity%20Spawner/V2/Example.lua)**
- **[Blitz Spawner Example](https://github.com/Focuslol666/Utilities/blob/patch-1/Doors/Entity%20Spawner/V2/Example_Blitz.lua)**
- **[Entity Repentance](https://github.com/Focuslol666/Utilities/blob/patch-1/Doors/Entity%20Spawner/Assets/Repentance.rbxm)**
- **[Crucifix](https://github.com/Focuslol666/Utilities/blob/patch-1/Doors/Entity%20Spawner/Crucifix.lua)**
## Modified
### Coming Soon
- **Update Ignore Hiding Places**
    - Have the entity ignore some of the hiding places and damage the player directly.
        > You can select hiding places to ignore.
### Released
- **Added Death Hints Isolation Floors**
    - When turned on, you can customize the death hints of each floors.
    > Main Floors: The Hotel, The Mines
    > Subfloors: The Backdoor, The Rooms, The Outdoors
    ```luau
    Death = {
        IsolationFloors = false, -- If true, you can customize different death hints on each floors, otherwise default death hints will be used.
        Type = "Guiding", -- "Curious"
        Hints = {"Death", "Hints", "Go", "Here"}, -- *Required!
        Cause = "",
        Floors = {
            Hotel = {
                Type = "Guiding", -- "Curious"
                Hints = {"Death", "Hints", "Go", "Here"},
                Cause = ""
            },
            Mines = {
                Type = "Guiding", -- "Curious"
                Hints = {"Death", "Hints", "Go", "Here"},
                Cause = ""
            }
        },
        Subfloors = {
            Backdoor = {
                Type = "Curious", -- "Guiding"
                Hints = {"Death", "Hints", "Go", "Here"},
                Cause = ""
            },
            Rooms = {
                Type = "Curious", -- "Guiding"
                Hints = {"Death", "Hints", "Go", "Here"},
                Cause = ""
            },
            Outdoors = {
                Type = "Curious", -- "Guiding"
                Hints = {"Death", "Hints", "Go", "Here"},
                Cause = ""
            }
        }
	}
    ```
---
- **Added Ignore Hiding Places**
    - Have the entity ignore some of the hiding places and damage the player directly.
    ```luau
    Damage = {
        -- Others...
        IgnoreHiding = { -- All hide places are disabled for entities such as Deer God
            Enabled = true
        }
	}
    ```
---
- **Added Crucified Callback**
    - This callback is triggered when the entity is crucified.
    - You can use `entity:SetCallback()` to customize the callback function.
    ```luau
    entity:SetCallback("OnCrucified", function(stateResist)
        print("Entity was crucified")
        task.wait(3)
        if stateResist == true then
            print("Entity is resisting the crucifixion")
        else
            print("The entity has been breaking by the crucifixion")
        end
    end)
    ```
---
- **Added Curious Light Crucifixion**
    - The effect of "Curious Light" appears when the entity is crucifixion.
    ```luau
    Crucifixion = {
        Type = "Curious", -- "Guiding"
        -- Others...
	}
    ```
---
- **Added Achievements**
    - After triggering some events, you will unlock achievements.
        > Achievement is unlocked when you survive the entity.
        > Achievement is unlocked when you used crucifix against the entity.
        > Achievement is unlocked when you died to the entity.
    ```luau
    Achievements = {
        Survive = {
            Enabled = true, -- Whether achievements will be displayed
            Once = false, -- Achievements will only be displayed once in this game
            Title = "Survive Title",
            Desc = "Survive Description",
            Reason = "Survive Reason",
            Image = "rbxassetid://YOUR_ASSET_ID"
        },
        Crucifix = {
            Enabled = true, -- Whether achievements will be displayed
            Once = false, -- Achievements will only be displayed once in this game
            Title = "Crucifix Title",
            Desc = "Crucifix Description",
            Reason = "Crucifix Reason",
            Image = "rbxassetid://YOUR_ASSET_ID"
        },
        Death = {
            Enabled = true, -- Whether achievements will be displayed
            Once = false, -- Achievements will only be displayed once in this game
            Title = "Death Title",
            Desc = "Death Description",
            Reason = "Death Reason",
            Image = "rbxassetid://YOUR_ASSET_ID"
        }
	}
    ```
---
- **Added Jumpscare**
    - Jumpscare is enabled when a player is killed by an entity.
    ```luau
    Jumpscare = {
        Enabled = false,
        Face = "rbxassetid://YOUR_ASSET_ID",
        FacePosition = UDim2.new(0.5, 0, 0.5, 0),
        FaceSize = UDim2.new(0, 150, 0, 150),
        BackgroundColor = Color3.new(1, 1, 1), -- Original color
        BackgroundColor2 = Color3.new(0, 0, 0), -- Flashing color
        Sound = "rbxassetid://YOUR_ASSET_ID",
        SoundVolume = 5
	}
    ```
---
- **Added ColorCorrection effect**
    - Create `ColorCorrectionEffect` visual effect when the entity is spawned.
    ```luau
    Lights = {
        -- Others...
        ColorCorrection = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 0), -- Color3.new
            CameraShake = {10, 5, 2, 5}, -- Magnitude, Roughness, FadeIn, FadeOut
            Sound = {
                SoundId = "rbxassetid://0",
                Volume = 1
            },
            Duration = 5, -- The duration of the effect (Duration = FadeIn + FadeOut)
            FadeIn = 1, -- The fadeIn time of the effect
            FadeOut = 2 -- The fadeOut time of the effect
        }
	}
    ```
### Removed
- ~~**Following Player**~~
    - ~~The entity will following the player's movements (similar to `A-120`)~~