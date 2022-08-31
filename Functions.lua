return {
    IsClosure = is_synapse_function or iskrnlclosure or isexecutorclosure,
    SetIdentity = (syn and syn.set_thread_identity) or set_thread_identity or setthreadidentity or setthreadcontext,
    Request = (syn and syn.request) or http_request or request,
    QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport,
    LoadModule = function(name)
        for i, v in next, game:GetDescendants() do
            if v.ClassName == "ModuleScript" and v.Name == name then
                return require(v)
            end
        end
    end,
}
