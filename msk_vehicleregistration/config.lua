Config = {}
----------------------------------------------------------------
Config.Locale = 'de' -- 'de', 'en'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E // Change the Key in translation.lua too

Config.npcVoice = {
    enable = true, -- The NPC will say something to you
    inRange = 5.0,
    outRange = 5.0
}

Config.defaultTextUI = true -- Set false if you want to use a custom textui

Config.openTextUI = function(current)
    exports['okokTextUI']:Open(Translation[Config.Locale]['open_garage_textui']:format(current.label), 'darkblue', 'left')
    -- exports["esx_textui"]:TextUI(Translation[Config.Locale]['open_garage_textui']:format(current.label), 'info')
end

Config.closeTextUI = function()
    exports['okokTextUI']:Close()
    -- exports["esx_textui"]:HideUI()
end
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message)
    if IsDuplicityVersion() then -- serverside
        TriggerClientEvent('esx:showNotification', source, message)
    else -- clientside
        ESX.ShowNotification(message)
    end
end
----------------------------------------------------------------
Config.CustomBanner = true -- Set true to enable Custom Banner
Config.removeTitle = false -- If Custom Banner enabled, it will remove the Title from the NativeUI

Config.Banner = function() -- Banner for Garage
    return Sprite.New('banner_blue', 'banner_blue', 0, 0, 512, 128)
end
----------------------------------------------------------------
Config.Locations = {
    ['doj'] = {
        label = 'Zulassungsstelle',
        fee = {enable = true, price = 150, method = 'money'}, -- Fee to Register the Vehicle
        vehicleDistance = 30.0, -- Distance for Vehicles
        changePlate = {enable = true, price = 200, method = 'money'}, -- Set to false if you don't want that you can change the plate
        locations = {
            {x = 337.25, y = -1562.77, z = 30.3, h = 319.51}
        },

        blip = {enable = true, id = 498, color = 11, scale = 0.8},
        pedmodel = {enable = true, model = 'csb_trafficwarden', distance = 30.0},
        text3d = {enable = false, label = '~g~Open Registration Office', size = 0.8},
        marker = {enable = false, distance = 10.0, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}}
    },
}