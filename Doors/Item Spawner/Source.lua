--[[ Services ]]--

local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");

--[[ Variables ]]--

local localPlayer = players.LocalPlayer;
local gameData = replicatedStorage:WaitForChild("GameData");
local latestRoom = gameData:WaitForChild("LatestRoom");
local spawner = {};
local defaultConfig = {
    Spawning = {
        Offset = CFrame.new();
        MinRoom = 0;
        MaxRoom = 100;
        Chance = 100;
    };
    Locations = {
        Drawers = true;
        Tables = true;
        Chests = true;
        Floor = true;
    };
    Prompt = {
        Range = 7;
        Duration = 0;
    };
};
local selfModules = {
    functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))();
};

--[[ Misc Functions ]]--

function convertToModel(tool)
    tool = tool:Clone();
    local model = Instance.new("Model");
    local handle = tool.Handle;
    local descendants = tool:GetDescendants();

    for i = 1, #descendants do
        local desc = descendants[i];
        if desc:IsA("BasePart") and desc.Name ~= "Handle" then
            desc.Anchored = false;
            desc.CanCollide = false;
            local weld = Instance.new("WeldConstraint");
            weld.Part0 = handle;
            weld.Part1 = desc;
            weld.Parent = handle;
        end
        if desc.Parent == tool then
            desc.Parent = model;
        end
    end

    model.Name = tool.Name;
    handle.Name = "Root";
    handle.CanCollide = false;
    model.PrimaryPart = handle;
    
    return model;
end;

function spawnItemInRoom(item, room)
    local locations = {};
    local descendants = room:GetDescendants();
    for i = 1, #descendants do
        local desc = descendants[i];
        if desc:FindFirstChild("Main") then
            if desc.Name == "DrawerContainer" and item.Config.Locations.Drawers then
                locations[#locations + 1] = {desc.Main, desc.Main.CFrame - Vector3.new(0, 0.1, 0)};

            elseif desc.Name == "Table" and item.Config.Locations.Tables then
                locations[#locations + 1] = {desc.Main, desc.Main.CFrame + Vector3.new(0, desc.Main.Size.Y / 2, 0)};
                
            elseif desc.Name:find("Chest") and item.Config.Locations.Chests then
                locations[#locations + 1] = {desc.Main, desc.Main.CFrame};
            end
        elseif desc.Name == "Floor" and desc:IsA("BasePart") and desc.Parent.Name == "Parts" and item.Config.Locations.Floor then
            local size = (desc.Size.X < desc.Size.Z and desc.Size.X or desc.Size.Z) / 2;

            for _ = 1, 100 do
                local origin = desc.CFrame * CFrame.new(math.random(-size, size), 0, math.random(-size, size)) + Vector3.new(0, desc.Size.Y / 2 + 0.1, 0);
                if checkRegion(origin, 5) then
                    locations[#locations + 1] = {desc, origin};
                    break;
                end
            end
        end
    end

    if #locations > 0 then
        local location = locations[math.random(1, #locations)];
        item.Model:PivotTo(location[2] * item.Config.Spawning.Offset);
        local weld = Instance.new("WeldConstraint");
        weld.Part0 = location[1];
        weld.Part1 = item.Model.PrimaryPart;
        weld.Parent = item.Model.PrimaryPart;
        item.Model.Parent = workspace;

        --[[ on spawned ]]--
        task.defer(item.Debug.OnSpawned);
        
        --[[ on entered room ]]--
        local index = tonumber(room.Name);
        if latestRoom.Value == index then
            task.defer(item.Debug.OnEnteredItemRoom, room);
        else
            local latestChanged; latestChanged = latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
                if latestRoom.Value == index then
                    latestChanged:Disconnect();
                    task.defer(item.Debug.OnEnteredItemRoom, room);
                end
            end);
        end
    else
        warn("Failed to find suitable location in room:", room, "for item:", item);
    end
end;

function checkRegion(origin, size)
    if not regionPart then
        getgenv().regionPart = Instance.new("Part");
        regionPart.Name = "RegionPart";
        regionPart.Anchored = true;
        regionPart.CanCollide = false;
        regionPart.Transparency = 1;
        regionPart.Size = Vector3.new(size, size, size);
        regionPart.Parent = workspace;
        regionPart.Touched:Connect(function() end);
    end
    regionPart:PivotTo(origin);
    
    local touching = regionPart:GetTouchingParts();
    local flag = true;
    for i = 1, #touching do
        local p = touching[i];
        if p:IsA("BasePart") and p.Transparency < 1 and p.CanCollide and p.Name ~= "Floor" and not p.Name:find("Carpet") then
            flag = false;
            break;
        end
    end
    return flag;
end;

--[[ Functions ]]--

spawner.createItem = function(config)
    for i, v in next, defaultConfig do
        if config[i] == nil then
            config[i] = defaultConfig[i];
        end
    end
    config.Spawning.Chance = math.clamp(config.Spawning.Chance, 1, 100);

    local tool = LoadCustomInstance(config.Url);
    if tool then
        local model = convertToModel(tool);
        local prompt = Instance.new("ProximityPrompt");
        prompt.Name = "ModulePrompt";
        prompt.Style = Enum.ProximityPromptStyle.Custom;
        prompt.RequiresLineOfSight = false;
        prompt.HoldDuration = config.Prompt.Duration;
        prompt.MaxActivationDistance = config.Prompt.Range;
        prompt.Parent = model.PrimaryPart;

        local data = {
            Tool = tool;
            Model = model;
            Prompt = prompt;
            Config = config;
            Debug = {
                OnSpawned = function() end;
                OnPickedUp = function() end;
                OnEquipped = function() end;
                OnActivated = function() end;
                OnUnequipped = function() end;
                OnEnteredItemRoom = function() end;
            };
        };

        --[[ on pickup ]]--
        local interact; interact = prompt.Triggered:Connect(function()
            interact:Disconnect();
            model:Destroy();
            tool.Parent = localPlayer:WaitForChild("Backpack");
            task.defer(data.Debug.OnPickedUp);
        end);

        --[[ on equipped ]]--
        tool.Equipped:Connect(function() task.defer(data.Debug.OnEquipped); end);

        --[[ on activated ]]--
        tool.Activated:Connect(function() task.defer(data.Debug.OnActivated); end);

        --[[ on unequipped ]]--
        tool.Unequipped:Connect(function() task.defer(data.Debug.OnUnequipped); end);

        return data;
    else
        warn("Failed to load custom item");
    end
end;

spawner.spawnItem = function(item)
    local rooms = workspace.CurrentRooms:GetChildren();

    for i = 1, #rooms do
        local room = rooms[i];
        local index = tonumber(room.Name);
        if index >= item.Config.Spawning.MinRoom and index <= item.Config.Spawning.MaxRoom then
            local chance = math.random(1, 100);
            if chance <= item.Config.Spawning.Chance then
                spawnItemInRoom(item, room);
                return;
            end
        end
    end

    local roomAdded; roomAdded = workspace.CurrentRooms.ChildAdded:Connect(function(room)
        local index = tonumber(room.Name);
        if index >= item.Config.Spawning.MinRoom and index <= item.Config.Spawning.MaxRoom then
            local chance = math.random(1, 100);
            if chance <= item.Config.Spawning.Chance then
                roomAdded:Disconnect();
                task.delay(3, spawnItemInRoom, item, room);
            end
        end
    end);
end;

--[[ Main ]]--

return spawner;
