Config = {}
----------------------------------------------------------------
Config.Locale = 'de' -- 'de', 'en'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, info)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK VehicleSeller', message, info)
    else -- clientside
        MSK.Notification('MSK VehicleSeller', message, info)
    end
end
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E // Change the Key in translation.lua too
----------------------------------------------------------------
Config.Locations = {
    ['pdm'] = {
        coords = vec3(-44.82, -1081.87, 26.69),
        marker = {enable = true, type = 1, size = {a = 5.0, b = 5.0, c = 5.0}, color = {a = 255, b = 255, c = 255}}
    },
    ['würfelpark'] = {
        coords = vec3(227.31, -854.47, 29.94),
        marker = {enable = true, type = 1, size = {a = 5.0, b = 5.0, c = 5.0}, color = {a = 255, b = 255, c = 255}}
    },
}
----------------------------------------------------------------
Config.Database = {
    enable = true, -- If false then you have to add the vehicles to Config.VehicleClasses or Config.CustomVehiclePrices
    vehicles = 'vehicles', -- vehicles database table // ESX default: 'vehicles'
    model = 'model', -- model column in vehicles database table // ESX default: 'model'
    price = 'price', -- price column in vehicles database table // ESX default: 'price'
    percentage = 40 -- buyPrice - percentage = sellPrice
}

-- Config.Database will be ignored if this is set to true
Config.VehicleClasses = {
    enable = false, -- Set true so that all vehicles with the configured class will be sold for the same price 

    [0] = 100, -- Compacts
    [1] = 100, -- Sedans
    [2] = 100, -- SUVs
    [3] = 100, -- Coupes
    [4] = 100, -- Muscle
    [5] = 100, -- Sports Classics
    [6] = 100, -- Sports
    [7] = 100, -- Super
    [8] = 100, -- Motorcycles
    [9] = 100, -- Off-road
    [10] = 100, -- Industrial
    [11] = 100, -- Utility
    [12] = 100, -- Vans
    [13] = 100, -- Cycles
    [14] = 100, -- Boats
    [15] = 100, -- Helicopters
    [16] = 100, -- Planes
    [17] = 100, -- Service
    [18] = 100, -- Emergency
    [19] = 100, -- Military
    [20] = 100, -- Commercial
}

-- This will be called before Config.VehicleClasses
Config.CustomVehiclePrices = {
    -- !!! You have to use `` and not '' or "" !!!
    [`adder`] = 1000,
}