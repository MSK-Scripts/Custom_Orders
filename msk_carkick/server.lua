ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('msk_carkick:sendData')
AddEventHandler('msk_carkick:sendData', function(playerId, vehNetId)
	TriggerClientEvent('msk_carkick:leaveVehicle', playerId, vehNetId)
end)