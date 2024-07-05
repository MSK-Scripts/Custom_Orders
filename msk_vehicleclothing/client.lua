local LastSkin = {}

RegisterCommand('openJobTrunk', function(source, args, raw)
    local vehicle = ESX.Game.GetVehicleInDirection()
    if not DoesEntityExist(vehicle) then return end
    local vehicleModel = getIsVehicleAllowed(vehicle)
    print('vehicleModel', vehicleModel)
    if not vehicleModel then return end
    local jobName, gradeName, elements = ESX.PlayerData.job.name, ESX.PlayerData.job.grade_name, {{label = 'Eigene Kleidung', value = 'default'}}
    local isJobAndRankAllowed = getIsJobAndRankAllowed(vehicleModel, jobName, gradeName)
    print('isJobAndRankAllowed', isJobAndRankAllowed)
    if not isJobAndRankAllowed then return end
    ESX.UI.Menu.CloseAll()

    for k, v in pairs(Config.Settings[vehicleModel][jobName][gradeName]) do
        elements[#elements + 1] = {label = v.label, value = #elements + 1, skin = v.skin}
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'msk_kleidung_openJobTrunk', {
		title    = 'Kleidung',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
        if data.current.value == 'default' then
            local playerId = GetPlayerServerId(PlayerId())
            if LastSkin[playerId] then TriggerEvent('skinchanger:loadSkin', LastSkin[playerId]) end
        else
            for k, v in pairs(elements) do
                if k == data.current.value then
                    setPedClothing(data.current.skin)
                    break
                end
            end
        end
	end, function(data, menu)
		menu.close()
	end)
end)
RegisterKeyMapping('openJobTrunk', 'Öffne die Kleiderbox im Fahrzeug', 'keyboard', Config.Hotkey)

setPedClothing = function(skin)
    TriggerEvent('skinchanger:getSkin', function(playerSkin)
        local playerId = GetPlayerServerId(PlayerId())
        if not LastSkin[playerId] then LastSkin[playerId] = playerSkin end

        if playerSkin.sex == 0 then --male
            for k, v in pairs(skin.male) do
                TriggerEvent('skinchanger:change', k, v)
            end
        else -- female
            for k, v in pairs(skin.female) do
                TriggerEvent('skinchanger:change', k, v)
            end
        end
    end)
end

getIsVehicleAllowed = function(vehicle)
    local hash = GetEntityModel(vehicle)
    local name = GetDisplayNameFromVehicleModel(hash)

    for model, v in pairs(Config.Settings) do
        if model == name:lower() then
            return model
        end
    end

    return false
end

getIsJobAndRankAllowed = function(vehicleModel, jobName, gradeName)
    for job, v in pairs(Config.Settings[vehicleModel]) do
        if job == jobName then
            for grade, v2 in pairs(Config.Settings[vehicleModel][job]) do
                if grade == gradeName then
                    return true
                end
            end
        end
    end

    return false
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local playerId = GetPlayerServerId(PlayerId())
        if LastSkin[playerId] then TriggerEvent('skinchanger:loadSkin', LastSkin[playerId]) end
    end
end)