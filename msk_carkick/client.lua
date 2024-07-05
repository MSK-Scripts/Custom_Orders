ESX = exports.es_extended:getSharedObject()
local targetPlayer = {}

if Config.Command.enable then
    RegisterCommand(Config.Command.command, function(source, args, rawCommand)
        checkVehicle()
    end)
end

checkVehicle = function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetVehiclePedIsIn(playerPed)

    if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        local elements = getElements(vehicle)
        openMenu(elements, vehicle)
    end
end
exports("openVehicleSeatMenu", checkVehicle)

getElements = function(vehicle)
    targetPlayer = {}
    local elements = {}
    local vehicleSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))

    for i = 1, vehicleSeats do 
        if i == 1 and not IsVehicleSeatFree(vehicle, -1) then
            elements[#elements + 1] = {label = 'Fahrer', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, -1)
        elseif i == 2 and not IsVehicleSeatFree(vehicle, 0) then
            elements[#elements + 1] = {label = 'Beifahrer', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 0)
        elseif i == 3 and not IsVehicleSeatFree(vehicle, 1) then
            elements[#elements + 1] = {label = 'Hinten Links', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 1)
        elseif i == 4 and not IsVehicleSeatFree(vehicle, 2) then
            elements[#elements + 1] = {label = 'Hinten Rechts', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 2)
        elseif i == 5 and not IsVehicleSeatFree(vehicle, 3) then
            elements[#elements + 1] = {label = 'Ganz Hinten Links', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 3)
        elseif i == 6 and not IsVehicleSeatFree(vehicle, 4) then
            elements[#elements + 1] = {label = 'Ganz Hinten Rechts', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 4)
        elseif i == 7 and not IsVehicleSeatFree(vehicle, 5) then
            elements[#elements + 1] = {label = 'Außen Links', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 5)
        elseif i == 8 and not IsVehicleSeatFree(vehicle, 6) then
            elements[#elements + 1] = {label = 'Außen Rechts', value = i}
            targetPlayer[i] = GetPedInVehicleSeat(vehicle, 6)
        end
    end
    return elements
end

openMenu = function(elements, vehicle)
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'msk_carkick', {
		title    = Translation[Config.Locale]['menu_header'],
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
        local action = data.current.value

        if action == 1 then
            ESX.ShowNotification(Translation[Config.Locale]['self_throw'])
        else
            local vehNetId = VehToNet(vehicle)
            local player = NetworkGetPlayerIndexFromPed(targetPlayer[action])
            local playerId = GetPlayerServerId(player)
            
            SetNetworkIdExistsOnAllMachines(vehNetId, true)
            TriggerServerEvent('msk_carkick:sendData', playerId, vehNetId)

            menu.close()
        end
    end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent('msk_carkick:leaveVehicle')
AddEventHandler('msk_carkick:leaveVehicle', function(vehNetId)
    local vehicle = NetToVeh(vehNetId)

	TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
end)