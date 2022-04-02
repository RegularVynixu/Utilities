--[[
     _____               _        _                     _           
    |  __ \             | |      | |                   | |          
    | |__) |   _ _______| | ___  | |     ___   __ _  __| | ___ _ __ 
    |  ___/ | | |_  /_  / |/ _ \ | |    / _ \ / _` |/ _` |/ _ \ '__|
    | |   | |_| |/ / / /| |  __/ | |___| (_) | (_| | (_| |  __/ |   
    |_|    \__,_/___/___|_|\___| |______\___/ \__,_|\__,_|\___|_|   

    Puzzle Loader v1.0.0a

    Scripting - Vynixu

    Documentation : N/A

    [ What's new? ]

    [+] Initial release

]]--

-- Services

local ReSt = game:GetService("ReplicatedStorage")
local HS = game:GetService("HttpService")
local RS = game:GetService("RunService")

-- Variables

local Puzzle = debug.getupvalue(require(ReSt.Game.Robbery.PuzzleFlow).Init, 3)
local Stored = {
    OnConnection = Puzzle.OnConnection,
    Hide = Puzzle.Hide,
}

local PuzzleLoader = {}

-- Functions

function PuzzleLoader.new(puzzleData)
    assert(puzzleData)
    assert(puzzleData.Grid, puzzleData.Solution)

    local canContinue = false

    local solution = {}
    for i, v in next, puzzleData.Solution do
        for i2, v2 in next, v do
            solution[#solution + 1] = v2 -- Stores solution so it can be compared with current grid
        end
    end

    Puzzle.Hide = function() end
    Puzzle:SetGrid(69420, puzzleData.Grid)

    Puzzle.OnConnection = function()
        local grid = {}
        for i, v in next, Puzzle.Grid do
            for i2, v2 in next, v do
                grid[#grid + 1] = v2 -- Stores current grid so it can be compared with solution
            end
        end
        
        -- Match current grid with solution
        local incorrect = false
        for i, v in next, grid do
            if v ~= solution[i] then
                incorrect = true
                break
            end
        end
        
        if not incorrect then
            Puzzle.OnConnection, Puzzle.Hide = Stored.OnConnection, Stored.Hide -- Reset Puzzle functions
            Puzzle:Hide()
            canContinue = true
        end
    end

    --

    Puzzle:Show()
    repeat RS.RenderStepped:Wait() until canContinue -- Yields until completed
end

-- Scripts

return PuzzleLoader
