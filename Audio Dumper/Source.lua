-- Services

local HS = game:GetService("HttpService")
local MS = game:GetService("MarketplaceService")

-- Files Setup

local Files = {
    Folder = "Dumped Sounds",
}

-- Functions

function SetupFiles()
    if not isfolder(Files.Folder) then
        makefolder(Files.Folder)
    end
end

function GetNumberId(soundId)
    return tonumber(({string.gsub(soundId, "%D", "")})[1])
end

function DumpSounds()
    local soundIds = {}
    for i, v in next, game:GetDescendants() do
        if v:IsA("Sound") then
            local numberId = GetNumberId(v.SoundId)
            if numberId and not table.find(soundIds, numberId) then
                table.insert(soundIds, numberId)
            end
        end
    end

    if #soundIds > 0 then
        local filePath = Files.Folder.. "/Dumped Sounds [".. game.PlaceId.. "].txt"
        local str = isfile(filePath) and readfile(filePath).. "\n" or ""

        for i, v in next, soundIds do
            local success, result = pcall(function()
                return MS:GetProductInfo(v)
            end)
            if success and not string.find(str, v) then
                str = str.. v.. "    ~    ".. result.Name.. (i < #soundIds and "\n" or "")
            end
        end

        SetupFiles()
        writefile(filePath, str)
    end
end

-- Scripts

DumpSounds()
