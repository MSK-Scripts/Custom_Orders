Config = {}
----------------------------------------------------------------
Config.Debug = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, info, duration)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Personalmenu', message, info, duration)
    else -- clientside
        MSK.Notification('MSK Personalmenu', message, info, duration)
    end
end
----------------------------------------------------------------
Config.Hotkey = 'f5' -- RegisterKeyMapping // Command: /personalmenu
Config.CustomBanner = {enable = true, removeTitle = false, banner = 'banner_blue', x = 512, y = 128}
Config.CuffItem = 'cuffs' -- Benötigtes Item um einen Spieler zu fesseln. Sollte wie in msk_handcuffs sein.
Config.UncuffItem = 'cuff_keys' -- Benötigtes Item um einen Spieler zu entfesseln. Sollte wie in msk_handcuffs sein.
Config.SocietyJobs = {'police', 'ambulance'} -- Jobs die sich zum Dienst anmelden/abmelden können
----------------------------------------------------------------
-- Rundfunk Farben // Muss der Job Name sein
Config.Farben = {
    ['police'] = '#006eff',
    ['ambulance'] = '#750202',
    ['taxi'] = '#ccb803',
}
----------------------------------------------------------------
-- Muss im Code selbst ebenfalls angepasst werden falls hier mehr dazu kommt !!!
-- client_menu.lua ab Zeile 377 bis Zeile 405
Config.Dienstausweise = {
    -- ['Ausweis Typ'] = {'job', 'job'},
    ['lspd'] = {'police', 'fib'},
    ['lsmd'] = {'ambulance'},
}