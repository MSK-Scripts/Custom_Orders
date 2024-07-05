RegisterServerEvent('msk_personalmenu:showNotification')
AddEventHandler('msk_personalmenu:showNotification', function(playerId, message, info)
	Config.Notification(playerId, message, info)
end)

RegisterServerEvent('msk_personalmenu:sendRundfunk')
AddEventHandler('msk_personalmenu:sendRundfunk', function(header, message)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	
	for k, xTarget in ipairs(ESX.GetExtendedPlayers()) do
		xTarget.triggerEvent('msk_personalmenu:sendRundfunkNotify', header, message, xPlayer.name, Config.Farben[xPlayer.job.name], 5000)
	end
end)

RegisterServerEvent('msk_personalmenu:onOffDuty')
AddEventHandler('msk_personalmenu:onOffDuty', function()
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local string = ('%s hat den Dienst verlassen'):format(xPlayer.name)

	if string.find(xPlayer.job.name, "off") then 
		string = ('%s hat den Dienst angetreten'):format(xPlayer.name)
		xPlayer.job.name = string.gsub(xPlayer.job.name, 'off', '')
		xPlayer.setJob(xPlayer.job.name, xPlayer.job.grade)
	else
		xPlayer.setJob('off' .. xPlayer.job.name, xPlayer.job.grade)
	end

	local xPlayers = ESX.GetExtendedPlayers('job', xPlayer.job.name)
	for _, xPlayer in pairs(xPlayers) do
		Config.Notification(xPlayer.source, string)
	end
end)

RegisterServerEvent('msk_personalmenu:useItem')
AddEventHandler('msk_personalmenu:useItem', function(itemName)
	local src = source
    ESX.UseItem(src, itemName)
end)

RegisterServerEvent('msk_personalmenu:giveItem')
AddEventHandler('msk_personalmenu:giveItem', function(action, playerId, name, count, label, weaponComponents)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(playerId)

	if exploitProtection(src, playerId) then return end

	if action:match('item') then
		if not xTarget.canCarryItem(name, count) then return Config.Notification(src, 'Der Spieler hat dafür keinen Platz mehr!', 'error') end
		xPlayer.removeInventoryItem(name, count)
		xTarget.addInventoryItem(name, count)

		Config.Notification(src, ('Du hast %s %s %s gegeben.'):format(GetPlayerName(playerId), count, label), 'success')
		Config.Notification(playerId, ('Du hast %s %s von %s erhalten.'):format(count, label, GetPlayerName(src)), 'info')
	elseif action:match('weapon') then
		if xTarget.hasWeapon(name) then return Config.Notification(src, ('Der Spieler %s hat diese Waffe bereits'):format(GetPlayerName(playerId)), 'error') end

		xPlayer.removeWeapon(name)
		xTarget.addWeapon(name, count)
		for k, component in ipairs(weaponComponents) do
			xTarget.addWeaponComponent(name, component)
		end

		Config.Notification(src, ('Du hast %s die Waffe %s mit %s Schuss gegeben.'):format(GetPlayerName(playerId), label, count), 'success')
		Config.Notification(playerId, ('Du hast die Waffe %s mit %s Schuss von %s erhalten.'):format(label, count, GetPlayerName(src)), 'info')
	elseif action:match('ammo') then
		if not xTarget.hasWeapon(name) then return Config.Notification(src, ('Der Spieler %s hat die keine %s'):format(GetPlayerName(playerId), label), 'error') end

		xPlayer.removeWeaponAmmo(name, count)
		xTarget.addWeaponAmmo(name, count)

		Config.Notification(src, ('Du hast %s %s Schuss von deiner %s gegeben.'):format(GetPlayerName(playerId), count, label), 'success')
		Config.Notification(playerId, ('Du hast %s Schuss für deine %s von %s erhalten.'):format(count, label, GetPlayerName(src)), 'info')
	end
end)

RegisterServerEvent('msk_personalmenu:throwItem')
AddEventHandler('msk_personalmenu:throwItem', function(action, name, count, label)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	if action:match('item') then
		xPlayer.removeInventoryItem(name, count)
		Config.Notification(src, ('Du hast %s %s weggeworfen.'):format(count, label))
	elseif action:match('weapon') then
		xPlayer.removeWeapon(name)
		Config.Notification(src, ('Du hast deine %s weggeworfen.'):format(label))
	end
end)

RegisterServerEvent('msk_personalmenu:giveMoney')
AddEventHandler('msk_personalmenu:giveMoney', function(account, playerId, money)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(playerId)
	local label = 'Bargeld'

	if account:match('black_money') then label = 'Schwarzgeld' end

	xPlayer.removeAccountMoney(account, money)
	xTarget.addAccountMoney(account, money)

	Config.Notification(src, ('Du hast %s %s%s %s gegeben.'):format(GetPlayerName(playerId), '$', MSK.Comma(money), label), 'success')
	Config.Notification(playerId, ('Du hast %s%s %s von %s erhalten.'):format('$', MSK.Comma(money), label, GetPlayerName(src)), 'info')
end)

RegisterServerEvent('msk_personalmenu:stealItem')
AddEventHandler('msk_personalmenu:stealItem', function(action, playerId, name, count, label, weaponComponents)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(playerId)

	if exploitProtection(src, playerId) then return end

	if action:match('item') then
		xPlayer.addInventoryItem(name, count)
		xTarget.removeInventoryItem(name, count)

		Config.Notification(src, ('Du hast dem Spieler %s %s %s abgenommen.'):format(GetPlayerName(playerId), count, label), 'success')
		Config.Notification(playerId, ('Dir wurde %s %s von %s abgenommen.'):format(count, label, GetPlayerName(src)), 'info')
	elseif action:match('weapon') then
		if xPlayer.hasWeapon(name) then return Config.Notification(src, ('Du hast bereits eine %s.'):format(label), 'error') end

		xPlayer.addWeapon(name)
		xTarget.removeWeapon(name, count)
		for k, component in ipairs(weaponComponents) do
			xPlayer.addWeaponComponent(name, component)
		end

		Config.Notification(src, ('Du hast dem Spieler %s seine %s abgenommen.'):format(GetPlayerName(playerId), label), 'success')
		Config.Notification(playerId, ('Dir wurde deine %s von %s abgenommen.'):format(label, GetPlayerName(src)), 'info')
	elseif action:match('ammo') then
		if not xPlayer.hasWeapon(name) then return Config.Notification(src, ('Du hast keine %s'):format(label), 'error') end

		xPlayer.addWeaponAmmo(name, count)
		xTarget.removeWeaponAmmo(name, count)

		Config.Notification(src, ('Du hast %s %s Schuss abgenommen.'):format(GetPlayerName(playerId), count), 'success')
		Config.Notification(playerId, ('Dir wurden %s Schuss von %s abgenommen'):format(count, GetPlayerName(src)), 'info')
	end
end)

RegisterServerEvent('msk_personalmenu:rob')
AddEventHandler('msk_personalmenu:rob', function(playerId)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(playerId)
	local money = xTarget.getAccount('money').money

	if exploitProtection(src, playerId) then return end

	xPlayer.addAccountMoney('money', money)
	xTarget.removeAccountMoney('money', money)

	Config.Notification(src, ('Du hast %s%s erbeutet.'):format('$', money), 'success')
	Config.Notification(playerId, 'Du wurdest gerade ausgeraubt.', 'info')
end)

RegisterServerEvent('msk_personalmenu:setJob')
AddEventHandler('msk_personalmenu:setJob', function(playerId, jobName, action)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(playerId)

	if exploitProtection(src, playerId) or xPlayer.job.grade_name ~= 'boss' then return end

	if action:match('hire') then
		if xTarget.job.name ~= 'unemployed' then return Config.Notification(src, ('%s ist bereits bei %s angestellt.'):format(xTarget.name, xTaget.job.label), 'error') end
		xTarget.setJob(jobName, 0)

		Config.Notification(src, ('Du hast %s als %s - %s angestellt.'):format(xTarget.name, xPlayer.job.label, xPlayer.job.grade_label), 'success')
		Config.Notification(playerId, ('Du wurdest als %s - %s angestellt.'):format(xPlayer.job.label, xPlayer.job.grade_label), 'info')
	elseif action:match('promote') then
		if xTarget.job.name ~= xPlayer.job.name then return end
		xTarget.setJob(jobName, xTarget.job.grade + 1)

		Config.Notification(src, ('Du hast %s zu %s - %s befördert.'):format(xTarget.name, xPlayer.job.label, xPlayer.job.grade_label), 'success')
		Config.Notification(playerId, ('Du wurdest zu %s - %s befördert.'):format(xPlayer.job.label, xPlayer.job.grade_label), 'info')
	elseif action:match('degrade') then
		if xTarget.job.name ~= xPlayer.job.name then return end
		xTarget.setJob(jobName, xTarget.job.grade - 1)

		Config.Notification(src, ('Du hast %s zu %s - %s degradiert.'):format(xTarget.name, xPlayer.job.label, xPlayer.job.grade_label), 'success')
		Config.Notification(playerId, ('Du wurdest zu %s - %s degradiert.'):format(xPlayer.job.label, xPlayer.job.grade_label), 'info')
	elseif action:match('cancel') then
		if xTarget.job.name ~= xPlayer.job.name then return end
		xTarget.setJob('unemployed', 0)

		Config.Notification(src, ('Du hast %s gekündigt.'):format(xTarget.name), 'success')
		Config.Notification(playerId, 'Du wurdest gekündigt', 'info')
	end
end)

RegisterServerEvent('msk_personalmenu:sellVehicle')
AddEventHandler('msk_personalmenu:sellVehicle', function(playerId, targetId, plate)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local xTarget = ESX.GetPlayerFromId(targetId)
	local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")

	MySQL.query('UPDATE owned_vehicles SET owner = @identifier WHERE (plate = @plate or plate = @trimmedPlate)', {
		['@identifier'] = xTarget.identifier,
		['@plate'] = plate,
		["@trimmedPlate"] = trimmedPlate
	})

	Config.Notification(playerId, 'Du hast das Fahrzeug erfolgreich verkauft!', 'success')
	Config.Notification(targetId, 'Du hast das Fahrzeug erfolgreich gekauft.', 'success')
end)

MSK.RegisterCallback('msk_personalmenu:getInventory', function(source, cb, playerId)
	local src = source
	local xPlayer

	if playerId then xPlayer = ESX.GetPlayerFromId(playerId) else xPlayer = ESX.GetPlayerFromId(src) end
	cb(xPlayer.inventory)
end)

MSK.RegisterCallback('msk_personalmenu:getLoadout', function(source, cb, playerId)
	local src = source
	local xPlayer

	if playerId then xPlayer = ESX.GetPlayerFromId(playerId) else xPlayer = ESX.GetPlayerFromId(src) end
	cb(xPlayer.loadout)
end)

MSK.RegisterCallback('msk_personalmenu:isOwned', function(source, cb, plate)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")
	local isVehicleOwner = false

	local vehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = @owner AND (plate = @plate or plate = @trimmedPlate)', { 
		["@owner"] = xPlayer.identifier,
		["@plate"] = plate,
		["@trimmedPlate"] = trimmedPlate
	})

	if vehicle[1] then isVehicleOwner = true end

	cb(isVehicleOwner)
end)

exploitProtection = function(playerId, targetId)
	local distance = #(GetEntityCoords(GetPlayerPed(playerId)) - GetEntityCoords(GetPlayerPed(targetId)))

	if distance >= 5.0 then
		DropPlayer(playerId, 'Exploit Protection by MSK Scripts')
		return true
	end

	return false
end

logging = function(code, ...)
    if not Config.Debug then return end
    local script = "[^2"..GetCurrentResourceName().."^0]"
    MSK.logging(script, code, ...)
end