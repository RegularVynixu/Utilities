-- Services
local Players = game:GetService("Players")

-- Variables
local localPlayer = Players.LocalPlayer

local module = {
    set_identity = set_thread_identity or setthreadidentity,
    get_identity = get_thread_identity or getthreadidentity,
    request = http_request or request
}

-- Functions
local function writeTempFile(content)
    local fileName = ("temp_%s.txt"):format(tick())
    writefile(fileName, content)
    local result = readfile(fileName)
    delfile(fileName)
    return result
end

module.LoadCustomAsset = function(url, httpMethod)
    assert(url ~= "", "URL cannot be empty.")
    if httpMethod == nil then
        httpMethod = "request"
    end
    httpMethod = httpMethod:lower()
    if getcustomasset then
        if isfile(url) then
            return getcustomasset(url, true)
        elseif url:sub(1, 4) == "http" then
            if httpMethod == "httpget" then
                return writeTempFile(game:HttpGet(url))
            elseif httpMethod == "request" then
                local r = request({Url = url, Method = "GET"})
                if r and r.Success then
                    return writeTempFile(r.Body)
                else
                    warn("Failed to load custom asset for: ".. url)
                end
            end
        end
    else
        warn("Executor doesn't support 'getcustomasset', bruh. Better hope the asset is rbxassetid.")
    end
    if url:find("rbxassetid") or tonumber(url) then
        return "rbxassetid://".. url:match("%d+")
    end
end

module.LoadCustomInstance = function(url)
    assert(url ~= "", "URL cannot be empty.")
    local success, result = pcall(function()
        return game:GetObjects(LoadCustomAsset(url, "request"))[1]
    end)
    if success then
        return result
    else
        warn("Failed to load custom instance for: ".. url)
    end
end

module.LoadCustomSound = function(url)
    assert(url ~= "", "URL cannot be empty.")
    return LoadCustomAsset(url, "httpget")
end

-- Main
for name, func in module do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end
return module
