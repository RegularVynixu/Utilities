-- Additional help: @ActualMasterOogway

-- \\ Services // --

local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

-- \\ Variables // --

local Module = {}

-- \\ Functions // --

local function timestampToMillis(timestamp: string | number | DateTime): number
    return
        (typeof(timestamp) == "string" and DateTime.fromIsoDate(timestamp).UnixTimestampMillis)
        or (typeof(timestamp) == "number" and timestamp)
        or timestamp.UnixTimestampMillis
end

-- \\ Main // --

Module.Require = function(s: string): any?
    local content = s
    if s:lower():sub(1, 4) == "http" then
        content = game:HttpGet(s)
    elseif isfile(s) then
        content = readfile(s)
    end

    local func, err = loadstring(content)
    if not func then
        error(debug.traceback("Failed to load module:\n"..s.."\nError: "..err))
    end
    return func()
end

Module.LoadCustomAsset = function(url: string): string?
    if getcustomasset then
        if url:lower():sub(1, 4) == "http" then
            local fileName = `temp_{tick()}.txt`
            local _, result = pcall(function()
                writefile(fileName, game:HttpGet(url))
                return getcustomasset(fileName, true)
            end)
            if isfile(fileName) then
                delfile(fileName)
            end
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

Module.LoadCustomInstance = function(url: string): Instance?
    local success, result = pcall(function()
        return game:GetObjects(Module.LoadCustomAsset(url))[1]
    end)
    return success and result or nil
end

Module.GetGameLastUpdate = function(): DateTime
    return DateTime.fromIsoDate(MarketplaceService:GetProductInfo(game.PlaceId).Updated)
end

Module.HasGameUpdated = function(timestamp: string | number | DateTime): boolean
    local millis = timestampToMillis(timestamp)
    if millis then
        return millis < Module.GetGameLastUpdate().UnixTimestampMillis
    end
    return false
end

Module.GetGitLastUpdate = function(owner: string, repo: string, filePath: string): DateTime
    local url = `https://api.github.com/repos/{owner}/{repo}/commits?per_page=1&path={filePath}`
    local success, result = pcall(HttpService.JSONDecode, HttpService, game:HttpGet(url))
    if not success then
        error(debug.traceback("Failed to get last commit for:\n"..url))
    end
    return DateTime.fromIsoDate(result[1].commit.committer.date)
end

Module.HasGitUpdated = function(owner: string, repo: string, filePath: string, timestamp: string | number | DateTime): boolean
    local millis = timestampToMillis(timestamp)
    if millis then
        return millis < Module.GetGitLastUpdate(owner, repo, filePath).UnixTimestampMillis
    end
    return false
end

Module.TruncateNumber = function(num: number, decimals: number): number
    local shift = 10 ^ (decimals and math.max(decimals, 0) or 0)
    return num * shift // 1 / shift
end

for name, func in next, Module do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end

return Module