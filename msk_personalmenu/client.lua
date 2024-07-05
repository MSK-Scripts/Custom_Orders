local isMenuOpen, isDead = false, false

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)

_menuPool = NativeUI.CreatePool()
local mainMenu

CreateThread(function()
    while true do
        local sleep = 200
        isMenuOpen = false

        if _menuPool:IsAnyMenuOpen() then 
            sleep = 0
            isMenuOpen = true
            _menuPool:ProcessMenus()
        end

        Wait(sleep)
    end
end)

RegisterCommand('personalmenu', function(source, args, raw)
    if isMenuOpen or isDead or exports.msk_handcuffs:getIsHandcuffed() then return end

    while not ESX.PlayerData.job do Wait(0) end
    openMenu()
end)
RegisterKeyMapping('personalmenu', 'Öffne Personalmenu', 'keyboard', Config.Hotkey)

openMenu = function()
    local background

    if Config.CustomBanner.enable then
        if Config.CustomBanner.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '')
        else
            mainMenu = NativeUI.CreateMenu('Personalmenu', '')
        end
        background = Sprite.New(Config.CustomBanner.banner, Config.CustomBanner.banner, 0, 0, Config.CustomBanner.x, Config.CustomBanner.y)
        setCutomBanner(mainMenu, background)
    else
        mainMenu = NativeUI.CreateMenu('Personalmenu', '')
    end
    _menuPool:Add(mainMenu)

    reopenMenu(mainMenu, background)

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

setCutomBanner = function(menu, background)
    if Config.CustomBanner.enable then menu:SetBannerSprite(background, true) end
end

reopenMenu = function(mainMenu, background)
    _menuPool:CloseAllMenus()
    
    interaction(mainMenu, background)
    brieftasche(mainMenu, background)
    inventory(mainMenu, background)
    licenses(mainMenu, background)
    skin(mainMenu, background)
    society(mainMenu, background)
    vehicle(mainMenu, background)
end

RegisterNetEvent('msk_personalmenu:sendRundfunkNotify')
AddEventHandler('msk_personalmenu:sendRundfunkNotify', function(header, message, playerName, color, time)
    SendNUIMessage({
        action = 'notify',
        header = header,
        message = message,
        playerName = playerName or 'Rundfunk Nachricht',
        color = Config.Farben[color] or '#006eff',
        time = time or 5000,
    })
end)