local isNear, shown = false, false

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        lib.closeAlertDialog()
    end
end)

CreateThread(function()
    while true do
        local sleep = 250
        isNear = false
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for k, v in pairs(Config.Locations) do
            local dist = #(playerCoords - v.coords)

            if dist <= 20.0 and IsPedInAnyVehicle(playerPed) then
                sleep = 0

                if v.marker.enable then 
                    DrawMarker(v.marker.type, v.coords.x, v.coords.y, v.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.marker.size.a, v.marker.size.b, v.marker.size.c, v.marker.color.a, v.marker.color.b, v.marker.color.c, 100, false, true, 0, false) 
                end

                if dist <= 2.5 and IsPedInAnyVehicle(playerPed) and (GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed), -1) == playerPed) then
                    isNear = true

                    if not shown then 
                        MSK.HelpNotification('Drücke ~g~E~s~ um dein Fahrzeug zu verkaufen.')
                    end

                    if IsControlJustReleased(0, Config.Hotkey) then
                        shown = true
                        openDialog()
                    end
                end
            end
        end

        if not isNear and shown then
            shown = false
        end

        Wait(sleep)
    end
end)

openDialog = function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local vehicleModel, vehicleClass = GetEntityModel(vehicle), GetVehicleClass(vehicle)
    local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(vehicleModel))

    local vehiclePrice = MSK.Trigger('msk_vehicleseller:getVehicleData', {vehicleModel, vehicleClass, vehicleName})
    if not vehiclePrice then shown = false return Config.Notification(nil, 'Es wurde vom Händler kein Fahrzeugpreis angegeben...', 'error') end

    local alert = lib.alertDialog({
        header = 'Fahrzeug verkaufen',
        content = ('Möchtest du %s wirklich für $%s verkaufen?'):format(vehicleName, vehiclePrice),
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Abbrechen',
            confirm = 'Bestätigen'
        }
    })

    if alert == 'confirm' then
        TriggerServerEvent('msk_vehicleseller:sellVehicle', GetVehicleNumberPlateText(vehicle), {vehicleModel, vehicleClass, vehicleName})
        ESX.Game.DeleteVehicle(vehicle)
    end
end

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end