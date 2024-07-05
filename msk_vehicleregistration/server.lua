AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		local alterTable = MySQL.query.await('ALTER TABLE owned_vehicles ADD COLUMN IF NOT EXISTS `registration` tinyint(3) DEFAULT 0;')

		if alterTable and alterTable.warningStatus == 0 then
			print('^2 Successfully ^3 altered ^2 table ^3 owned_vehicles ^0')
		end
	end
end)

RegisterServerEvent('msk_vehicleregistration:changePlate')
AddEventHandler('msk_vehicleregistration:changePlate', function(fee)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer and fee then xPlayer.removeAccountMoney(fee.method, fee.price) end
	Config.Notification(src, Translation[Config.Locale]['success_changed_plate']:format(plate))
end)

RegisterServerEvent('msk_vehicleregistration:registerVehicle')
AddEventHandler('msk_vehicleregistration:registerVehicle', function(plate, remove, fee)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")
	local action = 1

	if remove then action = 0 end

	MySQL.query('UPDATE owned_vehicles SET registration = @registration WHERE (plate = @plate or plate = @trimmedPlate)', {
		['@registration'] = action,
		['@plate'] = plate,
		["@trimmedPlate"] = trimmedPlate
	})

	if not src then return end
	if xPlayer and fee and fee.enable then xPlayer.removeAccountMoney(fee.method, fee.price) end

	if remove then
		Config.Notification(src, Translation[Config.Locale]['remove_registration']:format(plate))
	else
		Config.Notification(src, Translation[Config.Locale]['success_registered']:format(plate))
	end
end)

MSK.RegisterCallback('msk_vehicleregistration:isOwned', function(source, cb, plate)
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

	if isVehicleOwner then
		logging('debug', ('Vehicle ^3%s^0 is owned by the player ^3%s^0'):format(trimmedPlate, xPlayer.identifier))
		cb(true)
	else
		logging('debug', ('Vehicle ^3%s^0 is not owned by the player ^3%s^0'):format(trimmedPlate, xPlayer.identifier))
		cb(false)
	end
end)

MSK.RegisterCallback('msk_vehicleregistration:isRegistered', function(source, cb, plate)
	cb(getRegistration(plate))
end)

getRegistration = function(plate)
	local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")
	local vehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE (plate = @plate or plate = @trimmedPlate)', { 
		["@plate"] = plate,
		["@trimmedPlate"] = trimmedPlate
	})

	return getStringValue(vehicle[1].registration)
end
exports('getRegistration', getRegistration)

addRegistration = function(plate)
	TriggerEvent('msk_vehicleregistration:registerVehicle', plate)
end
exports('addRegistration', addRegistration)

removeRegistration = function(plate)
	TriggerEvent('msk_vehicleregistration:registerVehicle', plate, true)
end
exports('removeRegistration', removeRegistration)

getStringValue = function(registered)
	if not registered then return false end

    if type(registered) == 'boolean' then
        if registered then
            return true
        elseif not registered then
            return false
        end
    elseif type(registered) == 'string' then
        if registered == '1' then
            return true
        elseif registered == '0' then
            return false
        end
    elseif type(registered) == 'number' then
        if registered == 1 then
            return true
        elseif registered == 0 then
            return false
        end
    end
end

logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end