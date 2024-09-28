local currentRegistration = nil
local hadSpeak, isMenuOpen, isDead = false, false, false
local Blips, isPedLoaded = {}, {}

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    refreshBlips()
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer)
    refreshBlips()
end)
        
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    refreshBlips()
end)

CreateThread(function()
    local shown = false

    while true do
        local sleep = 200
        shown = false
        currentRegistration = nil

        for k, registration in pairs(Config.Locations) do
            for k2, location in pairs(registration.locations) do 
                local distance = Vdist(GetEntityCoords(PlayerPedId()), location.x, location.y, location.z)
                    
                if registration.pedmodel.enable then
                    local pedmodel = GetHashKey(registration.pedmodel.model)
                    local npcID = pedmodel .. '-' .. k .. '-' .. k2

                    if distance <= registration.pedmodel.distance then
                        if not isPedLoaded[npcID] or not isPedLoaded[npcID].loaded then
                            isPedLoaded[npcID] = {}

                            RequestModel(pedmodel)
                            while not HasModelLoaded(pedmodel) do
                                Wait(1)
                            end
                            local npc = CreatePed(4, pedmodel, location.x, location.y, location.z - 1.0, location.h, false, true)
                            FreezeEntityPosition(npc, true)	
                            SetEntityHeading(npc, location.h)
                            SetEntityInvincible(npc, true)
                            SetBlockingOfNonTemporaryEvents(npc, true)

                            logging('debug', 'Set NPC Registration', 'NPC:' .. npc, 'NPCID:' .. npcID)

                            isPedLoaded[npcID].loaded = true
                            isPedLoaded[npcID].inDistance = true
                            isPedLoaded[npcID].hash = pedmodel
                            isPedLoaded[npcID].pedmodel = registration.pedmodel.model
                            isPedLoaded[npcID].npc = npc
                            isPedLoaded[npcID].npcID = npcID
                            isPedLoaded[npcID].location = vec3(location.x, location.y, location.z)
                        end
                    else
                        if isPedLoaded[npcID] and isPedLoaded[npcID].loaded then
                            isPedLoaded[npcID].inDistance = false
                        end
                    end

                    if Config.npcVoice.enable then
                        for k, v in pairs(isPedLoaded) do
                            if isPedLoaded[v.npcID] and isPedLoaded[v.npcID].loaded then
                                local dist = #(GetEntityCoords(PlayerPedId()) - isPedLoaded[v.npcID].location)

                                if dist < Config.npcVoice.inRange and not isPedLoaded[v.npcID].hasSpeak then
                                    PlayPedAmbientSpeechNative(isPedLoaded[v.npcID].npc, 'GENERIC_HI', 'SPEECH_PARAMS_FORCE_NO_REPEAT_FRONTEND')
                                    isPedLoaded[v.npcID].hasSpeak = true
                                elseif dist > Config.npcVoice.outRange and isPedLoaded[v.npcID].hasSpeak then
                                    PlayPedAmbientSpeechNative(isPedLoaded[v.npcID].npc, 'GENERIC_BYE', 'SPEECH_PARAMS_FORCE_NO_REPEAT_FRONTEND')
                                    isPedLoaded[v.npcID].hasSpeak = false
                                end
                            end
                        end
                    end
                else
                    if distance <= registration.marker.distance then 
                        if registration.marker.enable then
                            DrawMarker(registration.marker.type, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, registration.marker.size.a, registration.marker.size.b, registration.marker.size.c, registration.marker.color.a, registration.marker.color.b, registration.marker.color.c, 100, false, true, 0, false)
                        end

                        if registration.text3d.enable then
                            MSK.Draw3DText(location, registration.text3d.label, registration.text3d.size)
                        end
                    end
                end

                if distance <= 5.0 then sleep = 0 end

                if distance <= 2.5 then
                    currentRegistration = registration

                    if not IsPedInAnyVehicle(PlayerPedId()) and not isMenuOpen and not isDead then
                        if not shown then
                            if Config.defaultTextUI then
                                MSK.HelpNotification(Translation[Config.Locale]['open']:format(currentRegistration.label))
                            elseif not Config.defaultTextUI then 
                                Config.openTextUI(currentRegistration)
                            end
                        end

                        if IsControlJustReleased(0, Config.Hotkey) then
                            shown = true
                            openMenu()
                        end
                    else
                        if shown then
                            if not Config.defaultTextUI then 
                                Config.closeTextUI()
                            end
                        end
                    end
                end
            end
        end

        if isMenuOpen and not currentRegistration then
            shown = false
            _menuPool:CloseAllMenus()
        end

        for k, v in pairs(isPedLoaded) do
            if v.loaded and not v.inDistance then
                logging('debug', 'Delete NPC Registration', 'NPC:' .. v.npc, 'NPCID' .. v.npcID)
                DeleteEntity(v.npc)
                SetModelAsNoLongerNeeded(v.hash)
                isPedLoaded[v.npcID] = {}
            end
        end

        Wait(sleep)
    end
end)

---- NativeUI ----
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

function openMenu()
    logging('debug', currentRegistration.label)
    _menuPool:Remove()
    _menuPool = NativeUI.CreatePool()
    local background

    if Config.CustomBanner then
        if Config.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '~b~')
        else
            mainMenu = NativeUI.CreateMenu(currentRegistration.label, '~b~')
        end
        background = Config.Banner()
        mainMenu:SetBannerSprite(background, true)
    else
        mainMenu = NativeUI.CreateMenu(currentRegistration.label, '~b~')
    end
    _menuPool:Add(mainMenu)

    local vehiclesInArea = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), currentRegistration.vehicleDistance)
    for k, vehicle in pairs(vehiclesInArea) do 
        local isRegistered = false
        local plate = GetVehicleNumberPlateText(vehicle)
        plate = plate:gsub("^%s*(.-)%s*$", "%1")
        local isOwned = MSK.TriggerCallback('msk_vehicleregistration:isOwned', plate)
        
        if isOwned then 
            local label = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
            local desc = ''

            if getRegistration(plate) then
                isRegistered = true
                desc = Translation[Config.Locale]['is_already_registered']
            else
                isRegistered = false
                desc = Translation[Config.Locale]['not_already_registered']
            end

            local vehicleList = _menuPool:AddSubMenu(mainMenu, label, ('%s %s | %s'):format(Translation[Config.Locale]['get_plate'], plate, desc))
            vehicleList.ParentItem:RightLabel('~b~→→→')

            if Config.CustomBanner then
                vehicleList:SetBannerSprite(background, true)
            end

            if isRegistered then
                local unregister = NativeUI.CreateItem('Fahrzeug abmelden', ('%s %s~s~ | %s'):format(Translation[Config.Locale]['get_plate'], plate, Translation[Config.Locale]['price']:format(currentRegistration.fee.price)))
                vehicleList:AddItem(unregister)

                unregister.Activated = function(sender, index)
                    removeRegistration(plate, currentRegistration.fee)
                    _menuPool:CloseAllMenus()
                    openMenu()
                end
            else
                local register = NativeUI.CreateItem('Fahrzeug anmelden', ('%s %s~s~ | %s'):format(Translation[Config.Locale]['get_plate'], plate, Translation[Config.Locale]['price']:format(currentRegistration.fee.price)))
                vehicleList:AddItem(register)

                register.Activated = function(sender, index)
                    addRegistration(plate, currentRegistration.fee)
                    _menuPool:CloseAllMenus()
                    openMenu()
                end
            end

            if currentRegistration.changePlate.enable then
                local changeplate = NativeUI.CreateItem('Kennzeichen ändern', ('%s %s~s~ | %s'):format(Translation[Config.Locale]['get_plate'], plate, Translation[Config.Locale]['price']:format(currentRegistration.changePlate.price)))
                vehicleList:AddItem(changeplate)
                
                changeplate.Activated = function(sender, index)
                    local input = lib.inputDialog('Kennzeichen ändern', {'Neues Kennzeichen'})

                    if input and input[1] then
                        changePlate(vehicle, input[1], currentRegistration.changePlate)
                        _menuPool:CloseAllMenus()
                        openMenu()
                    end
                end
            end
        end
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

function refreshBlips()
    CreateThread(function()
        for k, v in pairs(Blips) do
            RemoveBlip(v)
        end
        Blips = {}

        for k, registration in pairs(Config.Locations) do
            if registration.blip.enable then
                for k2, location in pairs(registration.locations) do
                    local blip = AddBlipForCoord(location.x, location.y, location.z)

                    SetBlipSprite(blip, registration.blip.id)
                    SetBlipScale(blip, registration.blip.scale)
                    SetBlipDisplay(blip, 4)
                    SetBlipColour(blip, registration.blip.color)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName('STRING') 
                    AddTextComponentString(registration.label)
                    EndTextCommandSetBlipName(blip)
                    
                    table.insert(Blips, blip)
                end
            end
        end
    end)
end
refreshBlips()

getRegistration = function(plate)
	local isRegistered = MSK.TriggerCallback('msk_vehicleregistration:isRegistered', plate)

	return isRegistered
end
exports('getRegistration', getRegistration)

addRegistration = function(plate, fee)
	TriggerServerEvent('msk_vehicleregistration:registerVehicle', plate, false, fee)
end
exports('addRegistration', addRegistration)

removeRegistration = function(plate, fee)
	TriggerServerEvent('msk_vehicleregistration:registerVehicle', plate, true, fee)
end
exports('removeRegistration', removeRegistration)

changePlate = function(vehicle, plate, fee)
    SetVehicleNumberPlateText(vehicle, plate)
    if (GetResourceState("AdvancedParking") == "started") then exports["AdvancedParking"]:UpdatePlate(vehicle, plate) end
    TriggerServerEvent('msk_vehicleregistration:changePlate', fee)
end
exports('changePlate', changePlate)

logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end