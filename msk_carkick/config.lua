Config = {}
Translation = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = true
----------------------------------------------------------------
Config.Command = {
    enable = true, 
    command = 'seatMenu'
}
----------------------------------------------------------------
-- Export to open the Menu
-- exports.msk_carkick:openVehicleSeatMenu()
----------------------------------------------------------------
Translation = {
    ['de'] = {
        ['menu_header'] = 'Personen im Fahrzeug',
        ['throw_out'] = 'Du wurdest aus dem Fahrzeug geworfen',
        ['self_throw'] = 'Du kannst dich nicht selbst aus dem Fahrzeug werfen!'
    },
}