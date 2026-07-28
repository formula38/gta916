local RESOURCE_NAME = GetCurrentResourceName()

CreateThread(function()
    Wait(1500)
    print(("[%-12s] client initialized"):format(RESOURCE_NAME))
end)

RegisterNetEvent("gta916-core:client:notify", function(text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text or "GTA916 event")
    EndTextCommandThefeedPostTicker(false, false)
end)
