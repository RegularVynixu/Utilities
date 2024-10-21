-- Additional help: @ActualMasterOogway

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Variables
local module = {}

-- Functions
local function timestampToMillis(timestamp: string | number | DateTime)
    return (typeof(timestamp) == "string" and DateTime.fromIsoDate(timestamp).UnixTimestampMillis) or (typeof(timestamp) == "number" and timestamp) or timestamp.UnixTimestampMillis
end

module.LoadCustomAsset = function(url: string)
    if getcustomasset then
        if url:lower():sub(1, 4) == "http" then
            local fileName = `temp_{tick()}.txt`
            writefile(fileName, game:HttpGet(url))
            local result = getcustomasset(fileName, true)
            delfile(fileName)
            return result

	elseif isfile(url) then
            return getcustomasset(url, true)
        end
    else
        warn("Executor doesn't support 'getcustomasset', rbxassetid only.")
    end
    if url:find("rbxassetid") or tonumber(url) then
        return "rbxassetid://"..url:match("%d+")
    end
    error(debug.traceback("Failed to load custom asset for:\n"..url))
end

module.LoadCustomInstance = function(url: string)
    local success, result = pcall(function()
        return game:GetObjects(module.LoadCustomAsset(url))[1]
    end)
    if success then
        return result
    end
end

module.GetGameLastUpdate = function()
    return DateTime.fromIsoDate(MarketplaceService:GetProductInfo(game.PlaceId).Updated)
end

module.HasGameUpdated = function(timestamp: string | number | DateTime)
    local millis = timestampToMillis(timestamp)
    if millis then
        return millis < module.GetGameLastUpdate().UnixTimestampMillis
    end
    return false
end

module.GetGitLastUpdate = function(owner: string, repo: string, filePath: string)
    local url = `https://api.github.com/repos/{owner}/{repo}/commits?per_page=1&path={filePath}`
    local success, result = pcall(HttpService.JSONDecode, HttpService, game:HttpGet(url))
    if not success then
        error(debug.traceback("Failed to get last commit for:\n"..url))
    end
    return DateTime.fromIsoDate(result[1].commit.committer.date)
end

module.HasGitUpdated = function(owner: string, repo: string, filePath: string, timestamp: string | number | DateTime)
    local millis = timestampToMillis(timestamp)
    if millis then
        return millis < module.GetGitLastUpdate(owner, repo, filePath).UnixTimestampMillis
    end
    return false
end

module.TruncateNumber = function(num: number, decimals: number)
    local shift = 10 ^ (decimals and math.max(decimals, 0) or 0)
	return num * shift // 1 / shift
end

-- Main
for name, func in module do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end

return module
