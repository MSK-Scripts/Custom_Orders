local OnlinePlayers = 0

setDiscordRichPresencse = function()
	local id = GetPlayerServerId(PlayerId())
	local name = GetPlayerName(PlayerId())

	SetDiscordAppId(Config.AppId)
	SetDiscordRichPresenceAsset(Config.Asset)
	SetDiscordRichPresenceAssetText(Config.ServerName)
	SetRichPresence(('%s/%s - ID: %s | Name: %s'):format(OnlinePlayers, Config.ServerSlots, id, name))

	local button = Config.Buttons
	if button['0'] then SetDiscordRichPresenceAction(0, button['0'].name, button['0'].link) end
	if button['1'] then SetDiscordRichPresenceAction(1, button['1'].name, button['1'].link) end
end
setDiscordRichPresencse()

RegisterNetEvent('msk_discordRichPresence:refreshPlayerCount', function(playerCount)
	OnlinePlayers = playerCount
	setDiscordRichPresencse()
end)