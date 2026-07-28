local RESOURCE_NAME = GetCurrentResourceName()

CreateThread(function()
    print(("[%-12s] server initialized"):format(RESOURCE_NAME))
end)

RegisterCommand("gta916ping", function(source)
    local msg = ("[%s] pong"):format(RESOURCE_NAME)

    if source == 0 then
        print(msg)
        return
    end

    TriggerClientEvent("chat:addMessage", source, {
        color = { 0, 200, 120 },
        multiline = false,
        args = { "GTA916", msg }
    })
end, false)
