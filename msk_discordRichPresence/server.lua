local OnlinePlayers = 0

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    OnlinePlayers = OnlinePlayers + 1
end)

AddEventHandler('playerDropped', function(reason)
    OnlinePlayers = OnlinePlayers - 1
end)

CreateThread(function()
    while true do
        local sleep = Config.Refresh * 1000

        TriggerClientEvent('msk_discordRichPresence:refreshPlayerCount', -1, OnlinePlayers)

        Wait(sleep)
    end
end)