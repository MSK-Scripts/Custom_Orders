CreateThread(function()
    for k, v in pairs(Config.Locations) do
        if v.blip.enable then
            local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            
            SetBlipSprite(blip, v.blip.id)
            SetBlipScale(blip, v.blip.scale)
            SetBlipDisplay(blip, 4)
            SetBlipColour(blip, v.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING') 
            AddTextComponentString('LifeInvader')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    local isNearPed, isPedLoaded = false, false

    while true do
        local sleep = 200
        isNearPed = false

        for k, v in pairs(Config.Locations) do
            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(v.coords.x, v.coords.y, v.coords.z))

            if v.pedmodel.enable then
                if dist <= v.pedmodel.distance then
                    sleep = 0
                    isNearPed = true

                    if not isPedLoaded then
                        RequestModel(GetHashKey(v.pedmodel.model))
                        while not HasModelLoaded(GetHashKey(v.pedmodel.model)) do
                            Wait(1)
                        end
                        npc = CreatePed(4, GetHashKey(v.pedmodel.model), v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.h, false, true)
                        FreezeEntityPosition(npc, true)	
                        SetEntityHeading(npc, v.coords.h)
                        SetEntityInvincible(npc, true)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        isPedLoaded = true
                    end
                end
            else
                if dist <= v.marker.distance then 
                    sleep = 0

                    if v.marker.enable then
                        DrawMarker(v.marker.type, v.coords.x, v.coords.y, v.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.marker.size.a, v.marker.size.b, v.marker.size.c, v.marker.color.a, v.marker.color.b, v.marker.color.c, 100, false, true, 0, false)
                    end
                end
            end

            if dist <= v.distance then
                sleep = 0
                helpNotification('Drücke ~g~E~s~ um für ~r~$'..Config.Price..'~s~ ~o~Werbung~s~ zu schalten')

                if IsControlJustPressed(0, Config.Hotkey) then
                    local input = CreateDialog('Werbetext')

                    if input then
                        TriggerServerEvent('lifeinvader:send', input)
                    end
                end
            end
        end

        if (isPedLoaded and not isNearPed) then
            DeleteEntity(npc)
            for k, v in pairs(Config.Locations) do
                SetModelAsNoLongerNeeded(GetHashKey(v.pedmodel.model))
            end
            isPedLoaded = false
        end
        
        Wait(sleep)
    end
end)

RegisterNetEvent('lifeinvader:sendToAll')
AddEventHandler('lifeinvader:sendToAll', function(text)
    advancedNotification(text, 'Lifeinvader', 'Werbung', 'CHAR_LIFEINVADER', true, 1)
end)

helpNotification = function(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

advancedNotification = function(text, title, subtitle, icon, flash, icontype)
    if not flash then flash = true end
    if not icontype then icontype = 1 end
    if not icon then icon = 'CHAR_HUMANDEFAULT' end

    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, flash, icontype, title, subtitle)
	DrawNotification(false, true)
end

CreateDialog = function(Text)
	AddTextEntry(Text, Text)
	DisplayOnscreenKeyboard(1, Text, "", "", "", "", "", 90)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0);
		Wait(0);
	end
	if (GetOnscreenKeyboardResult()) then
		local displayResult = GetOnscreenKeyboardResult()
		return displayResult
	end
end