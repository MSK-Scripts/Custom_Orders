Config = {}

-- With STANDALONE you won't be able to set a price
Config.Framework = 'ESX' -- ESX, QBCore or STANDALONE

Config.Hotkey = 38 -- default: 38 = E
Config.Price = 500 -- $500

Config.Locations = {
    {
        distance = 2.5, -- Distance to interact
        coords = {x = -1083.1912, y = -245.8945, z = 37.7632, h = 208.7467}, 
        blip = {enable = true, id = 77, color = 1, scale = 0.8}, 
        pedmodel = {enable = true, model = 'a_f_y_business_01', distance = 20.0}, -- Set enable = false to use Marker instead of NPC // Distance for spawn NPC
        marker = {enable = true, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}, distance = 10.0} -- Distance for show Marker
    },
}