local GPS = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(player, xPlayer, isNew)
	local data = MySQL.query.await('SELECT is_dead FROM users WHERE identifier = ?', {xPlayer.identifier})
	data = data[1]
	if not data then return end
	
	local isDead = false
	if type(data.is_dead) == 'boolean' then
		if data.is_dead then isDead = true end
	else
		if data.is_dead == 1 then isDead = true end
	end

	if not isDead then return end
	local playerPed = GetPlayerPed(xPlayer.source)

	GPS[xPlayer.source] = {
		source = xPlayer.source,
		netId = NetworkGetNetworkIdFromEntity(playerPed),
		coords = GetEntityCoords(playerPed)
	}

	local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
	for k, xPlayer in pairs(xPlayers) do
		TriggerClientEvent('msk_deathradar:activateGPS', xPlayer.source, GPS[src])
	end
end)

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local playerPed = GetPlayerPed(src)

	GPS[src] = {
		source = src,
		netId = NetworkGetNetworkIdFromEntity(playerPed),
		coords = GetEntityCoords(playerPed)
	}

	local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
	for k, xPlayer in pairs(xPlayers) do
		TriggerClientEvent('msk_deathradar:activateGPS', xPlayer.source, GPS[src])
	end
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
	local src = source
	removeBlipById(src)
end)

RegisterNetEvent('esx:playerLogout', function(source)
    local src = source
	removeBlipById(src)
end)

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
	local src = playerId
	removeBlipById(src)
end)

removeBlipById = function(playerId)
	if not GPS[playerId] then return end
	GPS[playerId] = nil

	local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
	for k, xPlayer in pairs(xPlayers) do
		xPlayer.triggerEvent('msk_deathradar:deactivateGPSById', playerId)
	end
end

CreateThread(function()
    while true do
        local sleep = Config.Refresh * 1000

		for playerId, info in pairs(GPS) do
            -- info = source, netId, coords
			info.coords = GetEntityCoords(GetPlayerPed(playerId))
		end

		local xPlayers = ESX.GetExtendedPlayers('job', 'ambulance')
		for k, xPlayer in pairs(xPlayers) do
			TriggerClientEvent('msk_deathradar:refreshBlips', xPlayer.source, GPS)
		end

        Wait(sleep)
    end
end)