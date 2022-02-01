-- Services

local HS = game:GetService("HttpService")

-- Variables

local Exploit = {
    request = (syn and syn.request) or request or http_request,
    getasset = getsynasset or getcustomasset,
}

local Utils = {}

-- Functions

function Utils:Create(class, properties, radius)
	local instance = Instance.new(class)

	for i, v in next, properties do
		if i ~= "Parent" then
			if typeof(v) == "Instance" then
				v.Parent = instance
			else
				instance[i] = v
			end
		end
	end

	if radius then
		local uicorner = Instance.new("UICorner", instance)
		uicorner.CornerRadius = radius
	end
    
	return instance
end

function Utils:LoadCustomAsset(url)
    if Exploit.request and Exploit.getasset then
        local data = Exploit.request({
            Url = url,
            Method = "GET",
        }).Body
    
        local fileName = "loadedAsset_".. tick().. ".txt"
        writefile(fileName, data)
        
        task.spawn(function()
            task.wait(3)
            if isfile(fileName) then
                delfile(fileName)
            end
        end)
        
        return Exploit.getasset(fileName)
    end
end

-- Scripts

return Utils
