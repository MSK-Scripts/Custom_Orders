local vehicles = {}

if Config.Method == 'fixed' then
    CreateThread(function()
        while true do
            local sleep = 500

            for k, v in pairs(Config.Locations) do
                local dist = #(GetEntityCoords(PlayerPedId()) - v.coords)
                local modelHash = GetHashKey(v.model)
                
                if dist <= v.distance then
                    if not vehicles[modelHash] or not vehicles[modelHash].loaded then
                        vehicles[modelHash] = {}

                        RequestModel(modelHash)
                        while not HasModelLoaded(modelHash) do
                            Wait(0)
                        end
                        local vehicle = CreateVehicle(modelHash, v.coords.x, v.coords.y, v.coords.z, v.heading, true, false)
                        FreezeEntityPosition(vehicle, true)	
                        SetEntityInvincible(vehicle, true)
                        SetBlockingOfNonTemporaryEvents(vehicle, true)
                        SetVehicleDoorsLocked(vehicle, 2)
                        SetVehicleCanBeLockedOn(vehicle, false, false)
                        if v.colors.enable then SetVehicleColours(vehicle, v.colors.primary, v.colors.secondary) end
                        if v.plate then SetVehicleNumberPlateText(vehicle, v.plate) end

                        vehicles[modelHash].loaded = true
                        vehicles[modelHash].inDistance = true
                        vehicles[modelHash].vehicle = vehicle
                        vehicles[modelHash].hash = modelHash
                        vehicles[modelHash].rotate = v.rotate
                    end
                else
                    if vehicles[modelHash] and vehicles[modelHash].inDistance then
                        vehicles[modelHash].inDistance = false
                    end
                end
            end

            for k, v in pairs(vehicles) do
                if v.loaded and not v.inDistance then
                    DeleteVehicle(v.vehicle)
                    SetModelAsNoLongerNeeded(v.hash)
                    vehicles[v.hash] = {}
                end
            end
            
            Wait(sleep)
        end
    end)

    CreateThread(function()
        while true do
            local sleep = 500

            for k, v in pairs(vehicles) do
                if v.loaded and v.inDistance and v.rotate.enable then
                    sleep = 0
                    local heading = GetEntityHeading(v.vehicle)
                    SetEntityHeading(v.vehicle, heading + v.rotate.speed)
                end
            end

            Wait(sleep)
        end
    end)
elseif Config.Method == 'self' then
    local veh = {}

    CreateThread(function()
        while true do
            local sleep = 1000

            ESX.TriggerServerCallback('msk_vehicleShowRoom:getVehicles', function(data)
               vehicles = data
            end)

            Wait(sleep)
        end
    end)

    CreateThread(function()
        local inRange = false

        while true do
            local sleep = 200
            inRange = false
            while not ESX.PlayerData.job do Wait(0) end

            for k, v in pairs(Config.Locations) do
                if not v.jobs.enable or (v.jobs.enable and isAllowed(v.jobs.jobs, ESX.PlayerData.job.name)) then
                    local dist = #(GetEntityCoords(PlayerPedId()) - v.coords)
                    
                    if dist <= v.distance then
                        sleep = 0
                        DrawMarker(Config.Type, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 150, false, true, 2, true, false, false, false)
                    end
    
                    if dist <= 2.5 then
                        inRange = true
                        ESX.ShowHelpNotification('~INPUT_CONTEXT~ Showroom öffnen')
    
                        if IsControlJustPressed(0, 38) then
                            openShowroomMenu(v.coords, v.distance)
                        end
                    end
                end
            end

            if not inRange then
                if ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'showroom') then
                    ESX.UI.Menu.CloseAll()
                end
            end
            
            Wait(sleep)
        end
    end)

    isAllowed = function(jobs, jobName)
        for k, job in pairs(jobs) do
            if job == jobName then
                return true
            end
        end
        return false
    end

    openShowroomMenu = function(coords, distance)
        ESX.UI.Menu.CloseAll()
        local isClear = ESX.Game.IsSpawnPointClear(coords, 5.0)
        
        if isClear then
            ESX.TriggerServerCallback('msk_vehicleShowRoom:getVehiclesFromDB', function(cars)
                local elements = {}

                for k, v in pairs(cars) do
                    table.insert(elements, {label = v.label, value = v.name})
                end

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'showroom', {
                    title    = 'Fahrzeugmenu',
                    align    = 'top-left',
                    elements = elements
                }, function(data, menu)
                    menu.close()
                    local vehicleModel = data.current.value
                    print(vehicleModel)

                    RequestModel(vehicleModel)
                    while not HasModelLoaded(vehicleModel) do
                        Wait(0)
                    end

                    local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
                    local netId = VehToNet(vehicle)

                    SetEntityAsMissionEntity(vehicle, true)
                    FreezeEntityPosition(vehicle, true)	
                    SetEntityInvincible(vehicle, true)
                    SetBlockingOfNonTemporaryEvents(vehicle, true)
                    SetVehicleDoorsLocked(vehicle, 2)
                    SetVehicleCanBeLockedOn(vehicle, false, false)
                    SetVehicleOnGroundProperly(vehicle)
                    SetNetworkIdCanMigrate(netId, true)
					SetVehRadioStation(vehicle, "OFF")
                    SetVehicleDirtLevel(vehicle, 0.0)
                    SetVehicleNumberPlateText(vehicle, 'Araziz')

                    veh[v.coords] = {coords = coords, netId = netId, loaded = true, inDistance = true}
                    vehicles[coords] = {coords = coords, netId = netId, model = vehicleModel, distance = distance}
                    TriggerServerEvent('msk_vehicleShowRoom:setVehicles', vehicles)
                end, function(data, menu)
                    menu.close()
                end)
            end)
        else
            local vehicle = ESX.Game.GetClosestVehicle()
            
            if DoesEntityExist(vehicle) then 
                local elements = {}
                table.insert(elements, {label = 'Fahrzeug löschen?', value = 'confirm'})

                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'showroom', {
                    title    = 'Fahrzeugmenu',
                    align    = 'top-left',
                    elements = elements
                }, function(data, menu)
                    menu.close()
                    local action = data.current.value
                    if action == 'confirm' then 
                        ESX.Game.DeleteVehicle(vehicle)
                        vehicles[coords] = nil
                        veh[v.coords] = nil
                        TriggerServerEvent('msk_vehicleShowRoom:setVehicles', vehicles)
                    end
                end, function(data, menu)
                    menu.close()
                end)
            end
        end
    end

    CreateThread(function()
        while true do
            local sleep = 200

            for k, v in pairs(vehicles) do
                local dist = #(GetEntityCoords(PlayerPedId()) - v.coords)
                local vehicleModel = v.model

                if dist <= v.distance then
                    if not veh[v.coords] or not veh[v.coords].loaded then
                        RequestModel(vehicleModel)
                        while not HasModelLoaded(vehicleModel) do
                            Wait(0)
                        end

                        local vehicle = CreateVehicle(vehicleModel, v.coords.x, v.coords.y, v.coords.z, GetEntityHeading(PlayerPedId()), true, false)
                        local netId = VehToNet(vehicle)

                        SetEntityAsMissionEntity(vehicle, true)
                        FreezeEntityPosition(vehicle, true)	
                        SetEntityInvincible(vehicle, true)
                        SetBlockingOfNonTemporaryEvents(vehicle, true)
                        SetVehicleDoorsLocked(vehicle, 2)
                        SetVehicleCanBeLockedOn(vehicle, false, false)
                        SetVehicleOnGroundProperly(vehicle)
                        SetNetworkIdCanMigrate(netId, true)
                        SetVehRadioStation(vehicle, "OFF")
                        SetVehicleDirtLevel(vehicle, 0.0)
                        SetVehicleNumberPlateText(vehicle, 'Araziz')

                        veh[v.coords] = {coords = coords, netId = netId, loaded = true, inDistance = true}
                    end
                else
                    if veh[v.coords] and veh[v.coords].inDistance then
                        veh[v.coords].inDistance = false
                    end
                end
            end

            for k, v in pairs(veh) do
                if v.loaded and not v.inDistance then
                    ESX.Game.DeleteVehicle(NetToVehicle(v.netId))
                    veh[v.coords] = {}
                end
            end

            Wait(sleep)
        end
    end)
end