local vehicles = {}

ESX.RegisterServerCallback('msk_vehicleShowRoom:getVehiclesFromDB', function(source, cb)
    local vehiclesList = {
        {name = 'nero2', label = 'Nero Custom'},
        {name = 'zentorno', label = 'Zentorno'},
    }

    cb(vehiclesList)
end)

ESX.RegisterServerCallback('msk_vehicleShowRoom:getVehicles', function(source, cb)
    cb(vehicles)
end)

RegisterNetEvent('msk_vehicleShowRoom:setVehicles', function(data)
    vehicles = data
    print(ESX.DumpTable(vehicles))
end)