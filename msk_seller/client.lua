local isPedLoaded, currentShopId, currentShop, isMenuOpen = {}, nil, nil, false

CreateThread(function()
    while true do
        currentShopId = nil
        currentShop = nil
        local sleep = 250
        local playerPed = ESX.PlayerData.ped
        local playerCoords = GetEntityCoords(playerPed)

        for itemName, v in pairs(Config.Locations) do
            local xyz = vec3(v.coords.x, v.coords.y, v.coords.z)
            local distance = #(playerCoords - xyz)

            if v.npc then
                local pedmodel = GetHashKey(v.npc)
                local npcID = pedmodel .. '-' .. itemName

                if distance <= 25.0 then
                    if not isPedLoaded[npcID] or not isPedLoaded[npcID].loaded then
                        isPedLoaded[npcID] = {}

                        RequestModel(pedmodel)
                        while not HasModelLoaded(pedmodel) do
                            Wait(1)
                        end
                        local npc = CreatePed(4, pedmodel, v.coords.x, v.coords.y, v.coords.z - 1.0, v.coords.w, false, true)
                        FreezeEntityPosition(npc, true)	
                        SetEntityHeading(npc, v.coords.w)
                        SetEntityInvincible(npc, true)
                        SetBlockingOfNonTemporaryEvents(npc, true)

                        isPedLoaded[npcID] = {
                            loaded = true, 
                            inDistance = true,
                            hash = pedmodel,
                            npc = npc,
                            npcID = npcID
                        }
                    end
                else
                    if isPedLoaded[npcID] and isPedLoaded[npcID].loaded then
                        isPedLoaded[npcID].inDistance = false
                    end
                end
            end

            if distance <= 2.5 then
                sleep = 0
                currentShopId = itemName
                currentShop = v

                ESX.ShowHelpNotification('Drücke ~g~E~s~ um zu verkaufen')

                if IsControlJustReleased(0, Config.Hotkey) then
                    openMenu()
                end
            end
        end

        if not currentShopId or not currentShop and isMenuOpen then
            ESX.UI.Menu.CloseAll()
        end

        for k, v in pairs(isPedLoaded) do
            if v.loaded and not v.inDistance then
                DeleteEntity(v.npc)
                SetModelAsNoLongerNeeded(v.hash)
                isPedLoaded[v.npcID] = {}
            end
        end
        
        Wait(sleep)
    end
end)

openMenu = function()
    isMenuOpen = true
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_seller', {
		title    = ('Möchtest du %s verkaufen?'):format(currentShop.itemLabel),
		align    = 'top-left',
		elements = {
            {label = 'Ja', value = 'yes'},
            {label = 'Nein', value = 'no'},
        }
	}, function(data, menu)
		if data.current.value == 'yes' then
            menu.close()
            
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'seller_amount', {
                title = 'Anzahl'
            }, function(data2, menu2)
                menu2.close()
                local amount = data2.value
                TriggerServerEvent('msk_seller:sellItem', currentShopId, tonumber(amount))
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == 'no' then
            menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end