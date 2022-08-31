getgenv().StoredModules = { Names = {}, Objects = {} }

local functions = {
    IsClosure = is_synapse_function or iskrnlclosure or isexecutorclosure,
    SetIdentity = (syn and syn.set_thread_identity) or set_thread_identity or setthreadidentity or setthreadcontext,
    Request = (syn and syn.request) or http_request or request,
    QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport,
    LoadModule = function(name)
        if #StoredModules == 0 then
            for _, v in next, game:GetDescendants() do
                if v.ClassName == "ModuleScript" then
                    StoredModules.Names[#StoredModules.Names + 1] = v.Name
                    StoredModules.Objects[#StoredModules.Objects + 1] = v
                end
            end
        end

        local nameIdx = table.find(StoredModules.Names, name)

        if not nameIdx then
            for _, v in next, game:GetDescendants() do
                if v.ClassName == "ModuleScript" and v.Name == name then
                    StoredModules.Names[#StoredModules.Names + 1] = v.Name
                    StoredModules.Objects[#StoredModules.Objects + 1] = v

                    return require(v)
                end
            end
        else
            return require(StoredModules.Objects[nameIdx])
        end
    end,
}

for i, v in next, functions do
    getgenv()[i] = v
end

return functions
