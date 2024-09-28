Vehicles = {}
Vehicles.Database = {}
Vehicles.VehicleClasses = {}
Vehicles.CustomVehiclePrices = {}

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Wait(100)
		if Config.Database.enable then
        	local data = MySQL.query.await(("SELECT * FROM %s"):format(Config.Database.vehicles))

			if data then
				for k, v in pairs(data) do
					Vehicles.Database[v[Config.Database.model]] = v[Config.Database.price]
				end
			end
		end

		if Config.VehicleClasses.enable then
			for k, v in pairs(Config.VehicleClasses) do
				if k ~= 'enable' then
					Vehicles.VehicleClasses[k] = v
				end
			end

			for k, v in pairs(Config.CustomVehiclePrices) do
				Vehicles.CustomVehiclePrices[k] = v
			end
		end
    end
end)

MSK.Register('msk_vehicleseller:getVehicleData', function(source, tbl)
	local model, class, name = tbl[1], tbl[2], tbl[3]:lower()
	local price = getVehicleFromDB(name) or getVehicleFromCustom(model) or getVehicleFromClass(class)
	return price
end)

RegisterServerEvent('msk_vehicleseller:sellVehicle')
AddEventHandler('msk_vehicleseller:sellVehicle', function(plate, tbl)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")

	local data = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = @identifier AND (plate = @plate or plate = @trimmedPlate)', {
		['@identifier'] = xPlayer.identifier,
		['@plate'] = plate,
		['@trimmedPlate'] = trimmedPlate
	})

	if data and data[1] then
		local model, class, name = tbl[1], tbl[2], tbl[3]:lower()
		local price = getVehicleFromDB(name) or getVehicleFromCustom(model) or getVehicleFromClass(class)
		xPlayer.addAccountMoney('bank', price)

		MySQL.query('DELETE FROM owned_vehicles WHERE owner = @identifier AND (plate = @plate or plate = @trimmedPlate)', { 
            ['@identifier'] = xPlayer.identifier,
            ['@plate'] = plate,
            ["@trimmedPlate"] = trimmedPlate
        })

		Config.Notification(src, ('Du hast dein Fahrzeug erfolgreich für $%s verkauft.'):format(price), 'success')
	else
		Config.Notification(src, 'Das Fahrzeug gehört dir nicht!', 'error')
	end
end)

getVehicleFromDB = function(vehicleName)
	return getPrice(Vehicles.Database[vehicleName])
end

getVehicleFromClass = function(vehicleClass)
	return Vehicles.VehicleClasses[vehicleClass]
end

getVehicleFromCustom = function(vehicleModel)
	return Vehicles.CustomVehiclePrices[vehicleModel]
end

getPrice = function(number)
	if not number then return end
	number = tonumber(number)
	return number - number * getPercent()
end

getPercent = function()
	local percentage, percent = Config.Database.percentage, 0

    if percentage <= 9 then
        percent = '0.0' .. percentage
    elseif percentage >= 10 and percentage <= 99 then
        percent = '0.' .. percentage
    elseif percentage == 100 then
        percent = 1.0
    end

	return tonumber(percent)
end

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/MSK-Scripts/msk_dustbin/main/VERSION', function(Error, NewestVersion, Header)
            print("###############################")
            if not NewestVersion then print(resourceName .. '^1 Update Check failed! ^3Please Update to the latest Version: ^9https://github.com/MSK-Scripts/msk_dustbin^0') return print("###############################") end
            if CurrentVersion == NewestVersion then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= NewestVersion then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here:^9 https://github.com/MSK-Scripts/msk_dustbin/releases/tag/v'.. NewestVersion .. '^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0')
        print("###############################")
    end
end
GithubUpdater()