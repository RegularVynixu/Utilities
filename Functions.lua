-- Variables
local module = {}

-- Functions
local function writeTempFile(content)
    local fileName = "temp_"..tick()..".txt"
    writefile(fileName, content)
    local result = getcustomasset(fileName, true)
    delfile(fileName)
    return result
end

module.LoadCustomAsset = function(url, httpMethod)
    url = url:lower()
    httpMethod = (httpMethod or "request"):lower()
    if getcustomasset then
        if isfile(url) then
            return getcustomasset(url, true)
        elseif url:sub(1, 4) == "http" then
            if httpMethod == "httpget" then
                return writeTempFile(game:HttpGet(url))
            elseif httpMethod == "request" then
                local r = request({Url = url, Method = "GET"})
                if r ~= nil and r.Success then
                    return writeTempFile(r.Body)
                end
            end
        end
    else
        warn("Executor doesn't support 'getcustomasset', rbxassetid only.")
    end
    if url:find("rbxassetid") or tonumber(url) then
        return "rbxassetid://"..url:match("%d+")
    end
    warn("Failed to load custom asset for:\n"..url)
end

module.LoadCustomInstance = function(url)
    local success, result = pcall(function()
        return game:GetObjects(LoadCustomAsset(url, "request"))[1]
    end)
    if success then
        return result
    end
end

-- Main
for name, func in module do
    if typeof(func) == "function" then
        local g = getgenv()
        if not g[name] then
            g[name] = func
        else
            warn("Failed to load global utility function '"..name.."' as it already exists.")
        end
    end
end
return module
