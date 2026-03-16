--[[
    This loadstring for DOORS Entity Spawner V2 is now deprecated.
    Please use the new loadstring below to remain up to date:

    https://raw.githubusercontent.com/RegularVynixu/DOORS-Entity-Spawner-V2/main/init.luau
]]--

local Spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/DOORS-Entity-Spawner-V2/main/init.luau"))()

local Module = {
    Create = function(config: any): any?
        return Spawner:Create(config)
    end,
    Run = function(entity: any)
        Spawner:Run(entity, false)
    end
}

getgenv().vynixu_SpawnerLoaded = getgenv()._internal_vynixu_entity_spawner

return Module
