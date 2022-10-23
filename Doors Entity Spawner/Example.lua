local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()

-- Create entity
local entity = Creator.createEntity({
    Model = "https://github.com/RegularVynixu/Miscellaneous/raw/main/Rush%20Model.rbxm",
    Speed = 100,
    DelayTime = 2,
    HeightOffset = 3.5,
    CamShake = {
        true,
        {7.5, 15, 0.1, 1},
        100,
    },
    CanKill = true,
    BreakLights = true,
    FlickerLights = {
        true,
        1,
    },
    Cycles = {
        Min = 1,
        Max = 4,
        WaitTime = 2,
    },
    CustomDialog = {"Your custom", "death message", "goes here."},
})

-- Run the created entity
Creator.runEntity(entity)
