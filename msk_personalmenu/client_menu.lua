interaction = function(mainMenu, background)
    local interactionMenu = _menuPool:AddSubMenu(mainMenu, 'Interaktionen')
    setCutomBanner(interactionMenu, background)

    local cuff = NativeUI.CreateItem('Festnehmen', '')
    interactionMenu:AddItem(cuff)

    local uncuff = NativeUI.CreateItem('Entfesseln', '')
    interactionMenu:AddItem(uncuff)

    cuff.Activated = function(sender, index)
        exports.msk_handcuffs:cuffPlayer(Config.CuffItem)
    end

    uncuff.Activated = function(sender, index)
        exports.msk_handcuffs:uncuffPlayer(Config.UncuffItem)
    end

    local search = NativeUI.CreateItem('Durchsuchen', '')
    mainMenu:AddItem(search) -- interactionMenu:AddItem(search)

    search.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            local isHandcuffed = exports.msk_handcuffs:getIsHandcuffed({source = GetPlayerServerId(closestPlayer)})
            if not isHandcuffed then return Config.Notification(nil, 'Der Spieler wurde noch nicht festgenommen', 'error') end

            TriggerServerEvent('msk_personalmenu:showNotification', GetPlayerServerId(closestPlayer), 'Du wirst gerade durchsucht', 'info')
            _menuPool:CloseAllMenus()
            openSearchMenu(background, closestPlayer)
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local rob = NativeUI.CreateItem('Ausrauben', '')
    mainMenu:AddItem(rob) -- interactionMenu:AddItem(rob)

    rob.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            local isHandcuffed = exports.msk_handcuffs:getIsHandcuffed({source = GetPlayerServerId(closestPlayer)})
            if not isHandcuffed then return Config.Notification(nil, 'Der Spieler wurde noch nicht festgenommen', 'error') end

            TriggerServerEvent('msk_personalmenu:rob', GetPlayerServerId(closestPlayer))
            reopenMenu(mainMenu, background)
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end
end

openSearchMenu = function(background, closestPlayer)
    local mainMenu = nil

    if Config.CustomBanner.enable then
        if Config.CustomBanner.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '')
        else
            mainMenu = NativeUI.CreateMenu('Personalmenu', '')
        end
        setCutomBanner(mainMenu, background)
    else
        mainMenu = NativeUI.CreateMenu('Personalmenu', '')
    end
    _menuPool:Add(mainMenu)

    local targetId = GetPlayerServerId(closestPlayer)

    local items = _menuPool:AddSubMenu(mainMenu, 'Items')
    setCutomBanner(items, background)

    local weapons = _menuPool:AddSubMenu(mainMenu, 'Waffen')
    setCutomBanner(weapons, background)

    local inventory = MSK.TriggerCallback('msk_personalmenu:getInventory', targetId)
    for k, v in ipairs(inventory) do
        if v.count > 0 then
            local item = NativeUI.CreateItem(v.label, '')
            item:RightLabel(v.count .. 'x')
            items:AddItem(item)

            item.Activated = function(sender, index)
                local input = CreateDialog('Anzahl')

                if input and tonumber(input) then
                    if tonumber(input) <= v.count then
                        TriggerServerEvent('msk_personalmenu:stealItem', 'item', targetId, v.name, tonumber(input), v.label)
                        v.count = v.count - tonumber(input)
                        item:RightLabel(v.count .. 'x')
                    else
                        Config.Notification(nil, 'So viele Items hat der Spieler nicht!', 'error')
                    end
                end
            end
        end
    end

    local loadout = MSK.TriggerCallback('msk_personalmenu:getLoadout', targetId)
    for k, v in ipairs(loadout) do
        local weaponMenu = _menuPool:AddSubMenu(weapons, v.label, getComponents(v.name, v.components))
        setCutomBanner(weaponMenu, background)
        weaponMenu.ParentItem:RightLabel(v.ammo .. ' Schuss')

        local removeWeapon = NativeUI.CreateItem('Waffe abnehmen', '')
        weaponMenu:AddItem(removeWeapon)

        removeWeapon.Activated = function(sender, index)
            TriggerServerEvent('msk_personalmenu:stealItem', 'weapon', targetId, v.name, v.ammo, v.label, v.components)
            openSearchMenu(background, closestPlayer)
        end

        local removeAmmo = NativeUI.CreateItem('Munition abnehmen', '')
        weaponMenu:AddItem(removeAmmo)

        removeAmmo.Activated = function(sender, index)
            local input = CreateDialog('Anzahl')
            
            if input and tonumber(input) then
                if tonumber(input) <= v.ammo then
                    TriggerServerEvent('msk_personalmenu:stealItem', 'ammo', targetId, v.name, tonumber(input), v.label, v.components)
                    v.ammo = v.ammo - tonumber(input)
                    weaponMenu.ParentItem:RightLabel(v.ammo .. ' Schuss')
                else
                    Config.Notification(nil, 'So viel Munition hat der Spieler nicht!', 'error')
                end
            end
        end
    end

    while true do 
        Wait(1)
        local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(targetId)))

        if distance > 3.0 then 
            _menuPool:CloseAllMenus()    
            break
        end
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

inventory = function(mainMenu, background)
    local items = _menuPool:AddSubMenu(mainMenu, 'Inventar')
    setCutomBanner(items, background)

    local weapons = _menuPool:AddSubMenu(mainMenu, 'Waffeninventar')
    setCutomBanner(weapons, background)

    for k, v in ipairs(ESX.GetPlayerData().inventory) do
        if v.count > 0 then
            local item = _menuPool:AddSubMenu(items, v.label)
            setCutomBanner(item, background)
            item.ParentItem:RightLabel(v.count .. 'x')

            local use = NativeUI.CreateItem('Benutzen', '')
            item:AddItem(use)

            if v.usable then
                use.Activated = function(sender, index)
                    TriggerServerEvent('msk_personalmenu:useItem', v.name)
                    _menuPool:CloseAllMenus()
                end
            else
                use:SetRightBadge(BadgeStyle.Lock)
            end

            local give = NativeUI.CreateItem('Geben', '')
            item:AddItem(give)

            give.Activated = function(sender, index)
                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                    local input = CreateDialog('Anzahl')

                    if input and tonumber(input) then
                        if tonumber(input) <= v.count then
                            TriggerServerEvent('msk_personalmenu:giveItem', 'item', GetPlayerServerId(closestPlayer), v.name, tonumber(input), v.label)
                            v.count = v.count - tonumber(input)
                            item.ParentItem:RightLabel(v.count .. 'x')
                        else
                            Config.Notification(nil, 'So viele Items hast du nicht!', 'error')
                        end
                    end
                else
                    Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
                end
            end

            local thow = NativeUI.CreateItem('Wegwerfen', '')
            item:AddItem(thow)

            if v.canRemove then
                thow.Activated = function(sender, index)
                    local input = CreateDialog('Anzahl')

                    if input and tonumber(input) then
                        if tonumber(input) <= v.count then
                            TriggerServerEvent('msk_personalmenu:throwItem', 'item', v.name, tonumber(input), v.label)
                            v.count = v.count - tonumber(input)
                            item.ParentItem:RightLabel(v.count .. 'x')
                        else
                            Config.Notification(nil, 'So viele Items hast du nicht!', 'error')
                        end
                    end
                end
            else
                thow:SetRightBadge(BadgeStyle.Lock)
            end
        end
    end

    local loadout = MSK.TriggerCallback('msk_personalmenu:getLoadout')
    for k, v in ipairs(loadout) do
        local weapon = _menuPool:AddSubMenu(weapons, v.label, getComponents(v.name, v.components))
        setCutomBanner(weapon, background)
        weapon.ParentItem:RightLabel(v.ammo .. ' Schuss')

        local give = NativeUI.CreateItem('Waffe geben', '')
        weapon:AddItem(give)

        give.Activated = function(sender, index)
            local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

            if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                TriggerServerEvent('msk_personalmenu:giveItem', 'weapon', GetPlayerServerId(closestPlayer), v.name, v.ammo, v.label, v.components)
                reopenMenu(mainMenu, background)
            else
                Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
            end
        end

        local giveAmmo = NativeUI.CreateItem('Munition geben', '')
        weapon:AddItem(giveAmmo)

        giveAmmo.Activated = function(sender, index)
            local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

            if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                local input = CreateDialog('Anzahl')

                if input and tonumber(input) then
                    if tonumber(input) <= v.ammo then
                        TriggerServerEvent('msk_personalmenu:giveItem', 'ammo', GetPlayerServerId(closestPlayer), v.name, tonumber(input), v.label)
                        v.ammo = v.ammo - tonumber(input)
                        weapon.ParentItem:RightLabel(v.ammo .. ' Schuss')
                    else
                        Config.Notification(nil, 'So viel Munition hast du nicht!', 'error')
                    end
                end
            else
                Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
            end
        end

        local thow = NativeUI.CreateItem('Wegwerfen', '')
        weapon:AddItem(thow)

        thow.Activated = function(sender, index)
            TriggerServerEvent('msk_personalmenu:throwItem', 'weapon', v.name, nil, v.label)
            reopenMenu(mainMenu, background)
        end

        local components = _menuPool:AddSubMenu(weapon, 'Waffenkomponenten')
        setCutomBanner(components, background)

        for _, weaponComponent in pairs(v.components) do
            local componentName = ESX.GetWeaponComponent(v.name, weaponComponent).label
            local component = NativeUI.CreateItem(componentName, 'ENTER zum entfernen der Komponente')
            components:AddItem(component)

            component.Activated = function(sender, index)
                TriggerServerEvent('msk_weaponammo:removeWeaponComponent', v.name, weaponComponent)
                reopenMenu(mainMenu, background)
            end
        end
    end
end

brieftasche = function(mainMenu, background)
    local brieftascheMenu = _menuPool:AddSubMenu(mainMenu, 'Brieftasche')
    setCutomBanner(brieftascheMenu, background)

    local jobname = NativeUI.CreateItem('Beruf', '')
    jobname:RightLabel(ESX.PlayerData.job.label .. ' - ' .. ESX.PlayerData.job.grade_label)
    brieftascheMenu:AddItem(jobname)

    local cashMenu = _menuPool:AddSubMenu(brieftascheMenu, 'Bargeld')
    setCutomBanner(cashMenu, background)
    cashMenu.ParentItem:RightLabel('$' .. MSK.Comma(getAccount('money').money))

    local givecash = NativeUI.CreateItem('Geben', '')
    brieftascheMenu:AddItem(givecash) -- cashMenu:AddItem(givecash)

    givecash.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            local input = CreateDialog('Betrag')

            if input and tonumber(input) then
                if tonumber(input) <= ESX.PlayerData.money then
                    TriggerServerEvent('msk_personalmenu:giveMoney', 'money', GetPlayerServerId(closestPlayer), tonumber(input))
                    reopenMenu(mainMenu, background)
                else
                    Config.Notification(nil, 'So viel Geld hast du nicht!', 'error')
                end
            end
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local blackmoneyMenu = _menuPool:AddSubMenu(brieftascheMenu, 'Schwarzgeld')
    setCutomBanner(blackmoneyMenu, background)
    blackmoneyMenu.ParentItem:RightLabel('$' .. MSK.Comma(getAccount('black_money').money))

    local giveblackmoney = NativeUI.CreateItem('Geben', '')
    blackmoneyMenu:AddItem(giveblackmoney)

    giveblackmoney.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            local input = CreateDialog('Betrag')

            if input and tonumber(input) then
                TriggerServerEvent('msk_personalmenu:giveMoney', 'black_money', GetPlayerServerId(closestPlayer), tonumber(input))
                reopenMenu(mainMenu, background)
            end
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local bank = NativeUI.CreateItem('Bankkonto', '')
    bank:RightLabel('$' .. MSK.Comma(getAccount('bank').money))
    brieftascheMenu:AddItem(bank)

    local secondAccount = MSK.Trigger('msk_banking:getSecondAccount') -- bank, iban
    local secondbank = NativeUI.CreateItem('Zweitkonto', '')
    secondbank:RightLabel('$' .. MSK.Comma(secondAccount.bank or 0))
    brieftascheMenu:AddItem(secondbank)
end

licenses = function(mainMenu, background)
    local licenseMenu = _menuPool:AddSubMenu(mainMenu, 'Lizenzen')
    setCutomBanner(licenseMenu, background)

    local visitenkarte = NativeUI.CreateItem('Visitenkarten', '')
    licenseMenu:AddItem(visitenkarte)

    visitenkarte.Activated = function(sender, index)
        _menuPool:CloseAllMenus() 
        TriggerEvent('businessCard:openMenu')
    end

    local viewperso = NativeUI.CreateItem('Personalausweis ansehen', '')
    licenseMenu:AddItem(viewperso)

    viewperso.Activated = function(sender, index)
        local playerId = GetPlayerServerId(PlayerId())
        --TriggerServerEvent('jsfour-idcard:open', playerId, playerId)
        TriggerEvent('myDocuments:showForeignDocument', 'idcard', playerId)
    end

    local showperso = NativeUI.CreateItem('Personalausweis zeigen', '')
    licenseMenu:AddItem(showperso)

    showperso.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            --TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
            TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'idcard')
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local viewsociety = NativeUI.CreateItem('Dienstausweis ansehen', '')
    licenseMenu:AddItem(viewsociety)

    viewsociety.Activated = function(sender, index)
        local playerId = GetPlayerServerId(PlayerId())

        if MSK.TableContains(Config.Dienstausweise['lspd'], ESX.PlayerData.job.name) then
            TriggerEvent('myDocuments:showForeignDocument', 'lspd', playerId)
        elseif MSK.TableContains(Config.Dienstausweise['lsmd'], ESX.PlayerData.job.name) then
            TriggerEvent('myDocuments:showForeignDocument', 'lsmd', playerId)
        end
    end

    local showsociety = NativeUI.CreateItem('Dienstausweis zeigen', '')
    licenseMenu:AddItem(showsociety)

    showsociety.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            if MSK.TableContains(Config.Dienstausweise['lspd'], ESX.PlayerData.job.name) then
                TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'lspd')
            elseif MSK.TableContains(Config.Dienstausweise['lsmd'], ESX.PlayerData.job.name) then
                TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'lsmd')
            end
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local viewdrive = NativeUI.CreateItem('Führerschein ansehen', '')
    licenseMenu:AddItem(viewdrive)

    viewdrive.Activated = function(sender, index)
        local playerId = GetPlayerServerId(PlayerId())
        --TriggerServerEvent('jsfour-idcard:open', playerId, playerId, 'driver')
        TriggerEvent('myDocuments:showForeignDocument', 'drive', playerId)
    end

    local showdrive = NativeUI.CreateItem('Führerschein zeigen', '')
    licenseMenu:AddItem(showdrive)

    showdrive.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            --TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
            TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'drive')
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local viewboat = NativeUI.CreateItem('Bootsführerschein ansehen', '')
    licenseMenu:AddItem(viewboat)

    viewboat.Activated = function(sender, index)
        local playerId = GetPlayerServerId(PlayerId())
        TriggerEvent('myDocuments:showForeignDocument', 'boat', playerId)
    end

    local showboat = NativeUI.CreateItem('Bootsführerschein zeigen', '')
    licenseMenu:AddItem(showboat)

    showboat.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'boat')
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local viewair = NativeUI.CreateItem('Flugführerschein ansehen', '')
    licenseMenu:AddItem(viewair)

    viewair.Activated = function(sender, index)
        local playerId = GetPlayerServerId(PlayerId())
        TriggerEvent('myDocuments:showForeignDocument', 'fly', playerId)
    end

    local showair = NativeUI.CreateItem('Flugführerschein zeigen', '')
    licenseMenu:AddItem(showair)

    showair.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'fly')
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end

    local viewweapon = NativeUI.CreateItem('Waffenschein ansehen', '')
    licenseMenu:AddItem(viewweapon)

    viewweapon.Activated = function(sender, index)
        local playerId = GetPlayerServerId(PlayerId())
        --TriggerServerEvent('jsfour-idcard:open', playerId, playerId, 'weapon')
        TriggerEvent('myDocuments:showForeignDocument', 'weapon', playerId)
    end

    local showweapon = NativeUI.CreateItem('Waffenschein zeigen', '')
    licenseMenu:AddItem(showweapon)

    showweapon.Activated = function(sender, index)
        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

        if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
            --TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
            TriggerEvent('myDocuments:showDocumentToSomebody', GetPlayerServerId(closestPlayer), 'weapon')
        else
            Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
        end
    end
end

local playerSkin, armor = nil, 0
local hat, ear, glasses, mask, bproof, torso, neck, bag, gloves, pants, shoes = true, true, true, true, true, true, true, true, true, true, true
skin = function(mainMenu, background)
    local hatItem, glassesItem, maskItem, earItem, bproofItem, torsoItem, neckItem, bagItem, glovesItem, pantsItem, shoesItem = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

    local skinMenu = _menuPool:AddSubMenu(mainMenu, 'Kleidung')
    setCutomBanner(skinMenu, background)

    TriggerEvent('skinchanger:getSkin', function(skin)
        playerSkin = skin
    end)

    if playerSkin.helmet_1 > 0 then
        hatItem = NativeUI.CreateCheckboxItem('Hut', (hat and playerSkin.helmet_1 > 0) or (not hat and playerSkin.helmet_1 > 0), '')
        skinMenu:AddItem(hatItem)
    end

    if playerSkin.glasses_1 > 0 then
        glassesItem = NativeUI.CreateCheckboxItem('Brille', (glasses and playerSkin.glasses_1 > 0) or (not glasses and playerSkin.glasses_1 > 0), '')
        skinMenu:AddItem(glassesItem)
    end

    if playerSkin.mask_1 > 0 then
        maskItem = NativeUI.CreateCheckboxItem('Maske', (mask and playerSkin.mask_1 > 0) or (not mask and playerSkin.mask_1 > 0), '')
        skinMenu:AddItem(maskItem)
    end

    if playerSkin.ears_1 > 0 then
        earItem = NativeUI.CreateCheckboxItem('Ohr', (ear and playerSkin.ears_1 > 0) or (not ear and playerSkin.ears_1 > 0), '')
        skinMenu:AddItem(earItem)
    end

    if playerSkin.bproof_1 > 0 then
        bproofItem = NativeUI.CreateCheckboxItem('Weste', (bproof and playerSkin.bproof_1 > 0) or (not bproof and playerSkin.bproof_1 > 0), '')
        skinMenu:AddItem(bproofItem)
    end

    if playerSkin.torso_1 > 0 then 
        torsoItem = NativeUI.CreateCheckboxItem('Oberteil', (torso and playerSkin.torso_1 > 0) or (not torso and playerSkin.torso_1 > 0), '')
        skinMenu:AddItem(torsoItem)
    end

    if playerSkin.chain_1 > 0 then
        neckItem = NativeUI.CreateCheckboxItem('Kette', (neck and playerSkin.chain_1 > 0) or (not neck and playerSkin.chain_1 > 0), '')
        skinMenu:AddItem(neckItem)
    end

    if playerSkin.bags_1 > 0 then
        bagItem = NativeUI.CreateCheckboxItem('Tasche', (bag and playerSkin.bags_1 > 0) or (not bag and playerSkin.bags_1 > 0), '')
        skinMenu:AddItem(bagItem)
    end

    if getGlovesVariation(playerSkin.sex, playerSkin.arms) then
        glovesItem = NativeUI.CreateCheckboxItem('Handschuhe', gloves, '')
        skinMenu:AddItem(glovesItem)
    end

    if playerSkin.pants_1 > 0 then
        pantsItem = NativeUI.CreateCheckboxItem('Hose', (pants and playerSkin.pants_1 > 0) or (not pants and playerSkin.pants_1 > 0), '')
        skinMenu:AddItem(pantsItem)
    end

    if playerSkin.shoes_1 > 0 then
        shoesItem = NativeUI.CreateCheckboxItem('Schuhe', (shoes and playerSkin.shoes_1 > 0) or (not shoes and playerSkin.shoes_1 > 0), '')
        skinMenu:AddItem(shoesItem)
    end

    skinMenu.OnCheckboxChange = function(sender, item, checked_)
        if item == hatItem then
            hat = checked_
            
            if hat then
                taskAnimation("mp_masks@standard_car@ds@", "put_on_mask", 600)
                SetPedPropIndex(PlayerPedId(), 0, playerSkin.helmet_1, playerSkin.helmet_2, 2)
                Config.Notification(nil, 'Du hast deinen Helm/Hut angezogen.', 'success')
            else
                taskAnimation("missheist_agency2ahelmet", "take_off_helmet_stand", 1200)
                ClearPedProp(PlayerPedId(), 0)
                Config.Notification(nil, 'Du hast deinen Helm/Hut ausgezogen.', 'success')
            end
        elseif item == glassesItem then
            glasses = checked_

            if glasses then
                taskAnimation("clothingspecs", "take_off", 1400)
                SetPedPropIndex(PlayerPedId(), 1, playerSkin.glasses_1, playerSkin.glasses_2, 2)
                Config.Notification(nil, 'Du hast deine Brille angezogen.', 'success')
            else
                taskAnimation("clothingspecs", "take_off", 1400)
                ClearPedProp(PlayerPedId(), 1)
                Config.Notification(nil, 'Du hast deine Brille ausgezogen.', 'success')
            end
        elseif item == maskItem then
            mask = checked_

            if mask then
                taskAnimation("mp_masks@standard_car@ds@", "put_on_mask", 800)
                SetPedComponentVariation(PlayerPedId(), 1, playerSkin.mask_1, playerSkin.mask_2, 2)
                Config.Notification(nil, 'Du hast deine Maske angezogen.', 'success')
            else
                taskAnimation("mp_masks@standard_car@ds@", "put_on_mask", 800)
                SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 2)
                Config.Notification(nil, 'Du hast deine Maske ausgezogen.', 'success')
            end
        elseif item == earItem then
            ear = checked_

            if ear then
                taskAnimation("mp_cp_stolen_tut", "b_think", 900)
                SetPedPropIndex(PlayerPedId(), 2, playerSkin.ears_1, playerSkin.ears_2, 2)
                Config.Notification(nil, 'Du hast deine Brille angezogen.', 'success')
            else
                taskAnimation("mp_cp_stolen_tut", "b_think", 900)
                ClearPedProp(PlayerPedId(), 2)
                Config.Notification(nil, 'Du hast deine Brille ausgezogen.', 'success')
            end
        elseif item == bproofItem then
            bproof = checked_
            
            if bproof then
                taskAnimation("clothingtie", "try_tie_negative_a", 1200)
                SetPedArmour(PlayerPedId(), armor or 0)
                SetPedComponentVariation(PlayerPedId(), 9, playerSkin.bproof_1, playerSkin.bproof_2, 2)
                Config.Notification(nil, 'Du hast deine Weste angezogen.', 'success')
            else
                taskAnimation("clothingtie", "try_tie_negative_a", 1200)
                armor = GetPedArmour(PlayerPedId())
                SetPedArmour(PlayerPedId(), 0)
                SetPedComponentVariation(PlayerPedId(), 9, 0, 0, 2)
                Config.Notification(nil, 'Du hast deine Weste ausgezogen.', 'success')
            end
        elseif item == torsoItem then
            torso = checked_

            if torso then
                taskAnimation("clothingtie", "try_tie_negative_a", 1200)
                SetPedComponentVariation(PlayerPedId(), 11, playerSkin.torso_1, playerSkin.torso_2, 2)
                SetPedComponentVariation(PlayerPedId(), 8, playerSkin.tshirt_1, playerSkin.tshirt_2, 2)
                SetPedComponentVariation(PlayerPedId(), 3, playerSkin.arms, playerSkin.arms_2, 2) -- gloves
                SetPedComponentVariation(PlayerPedId(), 10, playerSkin.decals_1, playerSkin.decals_2, 0) -- decals
                Config.Notification(nil, 'Du hast dein Oberteil angezogen.', 'success')
            else
                taskAnimation("clothingtie", "try_tie_negative_a", 1200)

                if playerSkin.sex == 0 then
                    SetPedComponentVariation(PlayerPedId(), 11, 252, 0, 0)
                else
                    SetPedComponentVariation(PlayerPedId(), 11, 74, 0, 0)
                end
                
                SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 0)
                SetPedComponentVariation(PlayerPedId(), 3, 15, 0, 0) -- gloves
                SetPedComponentVariation(PlayerPedId(), 10, 0, 0, 0) -- decals
                Config.Notification(nil, 'Du hast dein Oberteil ausgezogen.', 'success')
            end
        elseif item == neckItem then
            neck = checked_
            
            if neck then
                taskAnimation("clothingtie", "try_tie_positive_a", 2100)
                SetPedComponentVariation(PlayerPedId(), 7, playerSkin.chain_1, playerSkin.chain_2, 2)
                Config.Notification(nil, 'Du hast deine Kette angezogen.', 'success')
            else
                taskAnimation("clothingtie", "try_tie_positive_a", 2100)
                SetPedComponentVariation(PlayerPedId(), 7, 0, 0, 2)
                Config.Notification(nil, 'Du hast deine Kette ausgezogen.', 'success')
            end
        elseif item == bagItem then
            bag = checked_
            
            if bag then
                taskAnimation("clothingtie", "try_tie_negative_a", 1200)
                SetPedComponentVariation(PlayerPedId(), 5, playerSkin.bags_1, playerSkin.bags_2, 2)
                Config.Notification(nil, 'Du hast deine Tasche angezogen.', 'success')
            else
                taskAnimation("clothingtie", "try_tie_negative_a", 1200)
                SetPedComponentVariation(PlayerPedId(), 5, 0, 0, 2)
                Config.Notification(nil, 'Du hast deine Tasche ausgezogen.', 'success')
            end
        elseif item == glovesItem then
            if torso then
                gloves = checked_

                if gloves then
                    taskAnimation("nmt_3_rcm-10", "cs_nigel_dual-10", 1200)
                    SetPedComponentVariation(PlayerPedId(), 3, playerSkin.arms, playerSkin.arms_2, 2)
                    Config.Notification(nil, 'Du hast deine Handschuhe angezogen.', 'success')
                else
                    taskAnimation("nmt_3_rcm-10", "cs_nigel_dual-10", 1200)
                    SetPedComponentVariation(PlayerPedId(), 3, getGlovesVariation(playerSkin.sex, playerSkin.arms), 0, 2)
                    Config.Notification(nil, 'Du hast deine Handschuhe ausgezogen.', 'success')
                end
            else
                Config.Notification(nil, 'Ziehe erst dein Oberteil wieder an!', 'error')
            end
        elseif item == pantsItem then
            pants = checked_
            
            if pants then
                taskAnimation("re@construction", "out_of_breath", 1300)
                SetPedComponentVariation(PlayerPedId(), 4, playerSkin.pants_1, playerSkin.pants_2, 2)
                Config.Notification(nil, 'Du hast deine Hose angezogen.', 'success')
            else
                taskAnimation("re@construction", "out_of_breath", 1300)

                if playerSkin.sex == 0 then 
                    SetPedComponentVariation(PlayerPedId(), 4, 61, 0, 0)
                else
                    SetPedComponentVariation(PlayerPedId(), 4, 14, 0, 0)
                end
                Config.Notification(nil, 'Du hast deine Hose ausgezogen.', 'success')
            end
        elseif item == shoesItem then
            shoes = checked_
            
            if shoes then
                taskAnimation("random@domestic", "pickup_low", 1200)
                SetPedComponentVariation(PlayerPedId(), 6, playerSkin.shoes_1, playerSkin.shoes_2, 2)
                Config.Notification(nil, 'Du hast deine Hose angezogen.', 'success')
            else
                taskAnimation("random@domestic", "pickup_low", 1200)

                if playerSkin.sex == 0 then 
                    SetPedComponentVariation(PlayerPedId(), 6, 34, 0, 0)
                else
                    SetPedComponentVariation(PlayerPedId(), 6, 35, 0, 0)
                end
                Config.Notification(nil, 'Du hast deine Hose ausgezogen.', 'success')
            end
        end
    end
end

society = function(mainMenu, background)
    local societyMenu

    if ESX.PlayerData.job.name == 'unemployed' then
        societyMenu = NativeUI.CreateItem('Unternehmensverwaltung', '')
        mainMenu:AddItem(societyMenu)
        societyMenu:SetRightBadge(BadgeStyle.Lock)
    else        
        societyMenu = _menuPool:AddSubMenu(mainMenu, 'Unternehmensverwaltung')
        setCutomBanner(societyMenu, background)

        local imDienst = string.find(ESX.PlayerData.job.name, "off")

        if MSK.TableContains(Config.SocietyJobs, {ESX.PlayerData.job.name, string.gsub(ESX.PlayerData.job.name, 'off', "")}) then
            local s = 'Zum Dienst anmelden'
            if not imDienst then s = 'Vom Dienst abmelden' end
            local dienst = NativeUI.CreateItem(s, '')
            societyMenu:AddItem(dienst)

            dienst.Activated = function(sender, index)
                TriggerServerEvent('msk_personalmenu:onOffDuty')
            end
        end

        local rundfunk = _menuPool:AddSubMenu(societyMenu, 'Rundfunk senden')
        rundfunk.ParentItem:RightLabel('→→→')
        setCutomBanner(rundfunk, background)

        local rundfunkHeader = NativeUI.CreateItem('Überschrift', '')
        rundfunk:AddItem(rundfunkHeader)

        local rundfunkMessage = NativeUI.CreateItem('Nachricht', '')
        rundfunk:AddItem(rundfunkMessage)

        local rundfunkConfirm = NativeUI.CreateItem('~g~Absenden', '')
        rundfunk:AddItem(rundfunkConfirm)

        local funkHeader, funkMessage = nil, nil
        rundfunk.OnItemSelect = function(sender, item, index)
            if item == rundfunkHeader then
                MSK.Input('Überschrift', 'Gebe die Überschrift an.', function(input)
                    if not input then return end
                
                    funkHeader = input
                    rundfunkHeader:RightLabel(input)
                end)
            elseif item == rundfunkMessage then
                MSK.Input('Nachricht', 'Gebe die Nachricht an.', true, function(input)
                    if not input then return end
                
                    funkMessage = input
                    print(funkMessage)
                    rundfunkMessage:RightLabel('Deine Nachricht...')
                end)
            elseif item == rundfunkConfirm then
                TriggerServerEvent('msk_personalmenu:sendRundfunk', funkHeader, funkMessage)
                _menuPool:CloseAllMenus()
            end
        end

        local placeholder = NativeUI.CreateItem('', '')
        societyMenu:AddItem(placeholder)

        local jobname = NativeUI.CreateItem('Beruf', '')
        jobname:RightLabel(ESX.PlayerData.job.label .. ' - ' .. ESX.PlayerData.job.grade_label)
        societyMenu:AddItem(jobname)

        if ESX.PlayerData.job.grade_name == 'boss' then
            local jobForExport = ESX.PlayerData.job.name
            if string.find(ESX.PlayerData.job.name, "off") then jobForExport = string.gsub(jobForExport, 'off', "") end
            local job = exports.msk_banking:getSocietyInfo(jobForExport)

            local konto = NativeUI.CreateItem('Kontostand', '')
            konto:RightLabel(ESX.PlayerData.job.label .. ' - $' .. MSK.Comma(job.bank))
            societyMenu:AddItem(konto)

            local placeholder = NativeUI.CreateItem('', '')
            societyMenu:AddItem(placeholder)

            local employees = _menuPool:AddSubMenu(societyMenu, 'Mitarbeiterliste')
            employees.ParentItem:RightLabel('→→→')
            setCutomBanner(employees, background)

            ESX.TriggerServerCallback('esx_society:getEmployees', function(data)
                for k, v in pairs(data) do
                    local employee = NativeUI.CreateItem(v.name, '')
                    employee:RightLabel(v.job.label .. ' - ' .. v.job.grade_label)
                    employees:AddItem(employee)
                end

                _menuPool:RefreshIndex()
            end, ESX.PlayerData.job.name)

            local hire = NativeUI.CreateItem('Mitarbeiter einstellen', '')
            societyMenu:AddItem(hire)

            hire.Activated = function(sender, index)
                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                    TriggerServerEvent('msk_personalmenu:setJob', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 'hire')
                else
                    Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
                end
            end

            local promote = NativeUI.CreateItem('Mitarbeiter befördern', '')
            societyMenu:AddItem(promote)

            promote.Activated = function(sender, index)
                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
        
                if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                    TriggerServerEvent('msk_personalmenu:setJob', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 'promote')
                else
                    Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
                end
            end

            local degrade = NativeUI.CreateItem('Mitarbeiter degradieren', '')
            societyMenu:AddItem(degrade)

            degrade.Activated = function(sender, index)
                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
        
                if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                    TriggerServerEvent('msk_personalmenu:setJob', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 'degrade')
                else
                    Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
                end
            end

            local cancel = NativeUI.CreateItem('Mitarbeiter kündigen', '')
            societyMenu:AddItem(cancel)

            cancel.Activated = function(sender, index)
                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
        
                if closestPlayer ~= -1 and closestPlayerDistance < 3.0 then
                    TriggerServerEvent('msk_personalmenu:setJob', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 'cancel')
                else
                    Config.Notification(nil, 'Es ist niemand in deiner Nähe.', 'error')
                end
            end
        end
    end
end

local Unterbodenbeleuchtung, lockInfo = true, 1
vehicle = function(mainMenu, background)
    local vehicleMenu = _menuPool:AddSubMenu(mainMenu, 'Fahrzeugverwaltung')
    setCutomBanner(vehicleMenu, background)

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId())

        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            if lockStatus == 1 then lockInfo = 2 elseif lockStatus == 2 then lockInfo = 1 end

            local vehicleLock = NativeUI.CreateItem('Fahrzeug Auf-/Abschließend', '')
            vehicleMenu:AddItem(vehicleLock)

            vehicleLock.Activated = function(sender, index)
                local isOwned = MSK.TriggerCallback('msk_personalmenu:isOwned', GetVehicleNumberPlateText(vehicle))

                if isOwned then
                    SetVehicleDoorsLocked(vehicle, lockInfo)

                    if lockInfo == 2 then 
                        lockInfo = 1 
                        Config.Notification(nil, 'Du hast das Fahrzeug abgeschlossen', 'success')
                    elseif lockInfo == 1 then
                        lockInfo = 2 
                        Config.Notification(nil, 'Du hast das Fahrzeug aufgeschlossen', 'success')
                    end
                else
                    Config.Notification(nil, 'Dieses Fahrzeug gehört dir nicht!', 'error')
                end
            end

            local engine = NativeUI.CreateItem('Motor Ein-/Ausschalten', '')
            vehicleMenu:AddItem(engine)

            engine.Activated = function(sender, index)
                TriggerEvent('msk_enginetoggle:Engine')
            end

            local anschnallen = NativeUI.CreateItem('An-/Abschnallen', '')
            vehicleMenu:AddItem(anschnallen)

            anschnallen.Activated = function(sender, index)
                TriggerEvent('anschnallen:set')
            end

            local vehicleDoors = _menuPool:AddSubMenu(vehicleMenu, 'Türen')
            setCutomBanner(vehicleDoors, background)

            local vehicleDoorFrontLeft = NativeUI.CreateItem('Fahrertür', '')
            vehicleDoors:AddItem(vehicleDoorFrontLeft)

            vehicleDoorFrontLeft.Activated = function(sender, index)
                local doorstatus = GetVehicleDoorAngleRatio(vehicle, 0)

                if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 0, false) else SetVehicleDoorOpen(vehicle, 0, false, false) end
            end

            local vehicleDoorFrontRight = NativeUI.CreateItem('Beifahrertür', '')
            vehicleDoors:AddItem(vehicleDoorFrontRight)

            vehicleDoorFrontRight.Activated = function(sender, index)
                local doorstatus = GetVehicleDoorAngleRatio(vehicle, 1)

                if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 1, false) else SetVehicleDoorOpen(vehicle, 1, false, false) end
            end

            local vehicleDoorNumber = GetNumberOfVehicleDoors(vehicle)
            if vehicleDoorNumber > 4 then
                local vehicleDoorRearLeft = NativeUI.CreateItem('Hinten Links', '')
                vehicleDoors:AddItem(vehicleDoorRearLeft)

                vehicleDoorRearLeft.Activated = function(sender, index)
                    local doorstatus = GetVehicleDoorAngleRatio(vehicle, 2)
    
                    if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 2, false) else SetVehicleDoorOpen(vehicle, 2, false, false) end
                end

                local vehicleDoorRearRight = NativeUI.CreateItem('Hinten Rechts', '')
                vehicleDoors:AddItem(vehicleDoorRearRight)

                vehicleDoorRearRight.Activated = function(sender, index)
                    local doorstatus = GetVehicleDoorAngleRatio(vehicle, 3)
    
                    if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 3, false) else SetVehicleDoorOpen(vehicle, 3, false, false) end
                end
            end

            local vehicleDoorBonnet = NativeUI.CreateItem('Motorhaube', '')
            vehicleDoors:AddItem(vehicleDoorBonnet)

            vehicleDoorBonnet.Activated = function(sender, index)
                local doorstatus = GetVehicleDoorAngleRatio(vehicle, 4)

                if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 4, false) else SetVehicleDoorOpen(vehicle, 4, false, false) end
            end

            local vehicleDoorBoot = NativeUI.CreateItem('Kofferraum', '')
            vehicleDoors:AddItem(vehicleDoorBoot)

            vehicleDoorBoot.Activated = function(sender, index)
                local doorstatus = GetVehicleDoorAngleRatio(vehicle, 5)

                if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 5, false) else SetVehicleDoorOpen(vehicle, 5, false, false) end
            end

            local isNeonEnabled = isNeonLightEnabled(vehicle)
            if isNeonEnabled then
                local vehicleUnterboden = NativeUI.CreateCheckboxItem('Unterbodenbeleuchtung', Unterbodenbeleuchtung, '')
                vehicleMenu:AddItem(vehicleUnterboden)

                vehicleMenu.OnCheckboxChange = function(sender, item, checked_)
                    if item == vehicleUnterboden then
                        Unterbodenbeleuchtung = checked_
                        DisableVehicleNeonLights(vehicle, not Unterbodenbeleuchtung)
                    end
                end
            end

            local vehicleInfo = _menuPool:AddSubMenu(vehicleMenu, 'Fahrzeuginformationen')
            vehicleInfo.ParentItem:RightLabel('→→→')
            setCutomBanner(vehicleInfo, background)
            setVehicleInfos(vehicleInfo, vehicle)
        else
            local anschnallen = NativeUI.CreateItem('An-/Abschnallen', '')
            vehicleMenu:AddItem(anschnallen)

            anschnallen.Activated = function(sender, index)
                TriggerEvent('anschnallen:set')
            end
        end
    else
        local vehicle, coords = MSK.GetVehicleInDirection()

        if vehicle and DoesEntityExist(vehicle) then
            local distance = #(GetEntityCoords(PlayerPedId()) - coords)

            if distance <= 3.0 then
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                if lockStatus == 1 then lockInfo = 2 elseif lockStatus == 2 then lockInfo = 1 end

                local vehicleLock = NativeUI.CreateItem('Fahrzeug Auf-/Abschließend', '')
                vehicleMenu:AddItem(vehicleLock)

                vehicleLock.Activated = function(sender, index)
                    local isOwned = MSK.TriggerCallback('msk_personalmenu:isOwned', GetVehicleNumberPlateText(vehicle))

                    if isOwned then
                        SetVehicleDoorsLocked(vehicle, lockInfo)

                        if lockInfo == 2 then 
                            lockInfo = 1 
                            Config.Notification(nil, 'Du hast das Fahrzeug abgeschlossen', 'success')
                        elseif lockInfo == 1 then
                            lockInfo = 2 
                            Config.Notification(nil, 'Du hast das Fahrzeug aufgeschlossen', 'success')
                        end
                    else
                        Config.Notification(nil, 'Dieses Fahrzeug gehört dir nicht!', 'error')
                    end
                end

                local kofferraum = NativeUI.CreateItem('Kofferraum öffnen', '')
                vehicleMenu:AddItem(kofferraum)

                kofferraum.Activated = function(sender, index)
                    local lockStatus = GetVehicleDoorLockStatus(vehicle)

                    if lockStatus == 2 then
                        Config.Notification(nil, 'Das Fahrzeug ist abgeschlossen', 'error')
                    elseif lockStatus == 1 then
                        _menuPool:CloseAllMenus() 
                        TriggerEvent('lils_trunk:openTrunk', vehicle, GetVehicleNumberPlateText(vehicle))
                    end
                end

                local vehicleDoors = _menuPool:AddSubMenu(vehicleMenu, 'Türen')
                vehicleDoors.ParentItem:RightLabel('→→→')
                setCutomBanner(vehicleDoors, background)

                local vehicleDoorFrontLeft = NativeUI.CreateItem('Fahrertür', '')
                vehicleDoors:AddItem(vehicleDoorFrontLeft)

                vehicleDoorFrontLeft.Activated = function(sender, index)
                    local doorstatus = GetVehicleDoorAngleRatio(vehicle, 0)

                    if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 0, false) else SetVehicleDoorOpen(vehicle, 0, false, false) end
                end

                local vehicleDoorFrontRight = NativeUI.CreateItem('Beifahrertür', '')
                vehicleDoors:AddItem(vehicleDoorFrontRight)

                vehicleDoorFrontRight.Activated = function(sender, index)
                    local doorstatus = GetVehicleDoorAngleRatio(vehicle, 1)

                    if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 1, false) else SetVehicleDoorOpen(vehicle, 1, false, false) end
                end

                local vehicleDoorNumber = GetNumberOfVehicleDoors(vehicle)
                if vehicleDoorNumber > 4 then
                    local vehicleDoorRearLeft = NativeUI.CreateItem('Hinten Links', '')
                    vehicleDoors:AddItem(vehicleDoorRearLeft)

                    vehicleDoorRearLeft.Activated = function(sender, index)
                        local doorstatus = GetVehicleDoorAngleRatio(vehicle, 2)
        
                        if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 2, false) else SetVehicleDoorOpen(vehicle, 2, false, false) end
                    end

                    local vehicleDoorRearRight = NativeUI.CreateItem('Hinten Rechts', '')
                    vehicleDoors:AddItem(vehicleDoorRearRight)

                    vehicleDoorRearRight.Activated = function(sender, index)
                        local doorstatus = GetVehicleDoorAngleRatio(vehicle, 3)
        
                        if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 3, false) else SetVehicleDoorOpen(vehicle, 3, false, false) end
                    end
                end

                local vehicleDoorBonnet = NativeUI.CreateItem('Motorhaube', '')
                vehicleDoors:AddItem(vehicleDoorBonnet)

                vehicleDoorBonnet.Activated = function(sender, index)
                    local doorstatus = GetVehicleDoorAngleRatio(vehicle, 4)

                    if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 4, false) else SetVehicleDoorOpen(vehicle, 4, false, false) end
                end

                local vehicleDoorBoot = NativeUI.CreateItem('Kofferraum', '')
                vehicleDoors:AddItem(vehicleDoorBoot)

                vehicleDoorBoot.Activated = function(sender, index)
                    local doorstatus = GetVehicleDoorAngleRatio(vehicle, 5)

                    if doorstatus > 0.0 then SetVehicleDoorShut(vehicle, 5, false) else SetVehicleDoorOpen(vehicle, 5, false, false) end
                end
                
                local vehicleSellMenu = _menuPool:AddSubMenu(vehicleMenu, 'Fahrzeug verkaufen')
                vehicleSellMenu.ParentItem:RightLabel('→→→')
                setCutomBanner(vehicleSellMenu, background)

                local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                local plate = GetVehicleNumberPlateText(vehicle)

                local vehicleSellName = NativeUI.CreateItem('Name', '')
                vehicleSellName:RightLabel(vehicleName)
                vehicleSellMenu:AddItem(vehicleSellName)

                local vehicleSellPlate = NativeUI.CreateItem('Kennzeichen', '')
                vehicleSellPlate:RightLabel(plate)
                vehicleSellMenu:AddItem(vehicleSellPlate)

                local vehicleSellPrice = NativeUI.CreateItem('Preis', '')
                vehicleSellPrice:RightLabel('$0')
                vehicleSellMenu:AddItem(vehicleSellPrice)

                local vehicleSellConfirm = NativeUI.CreateItem('~g~Rechnung übergeben', 'Übergebe die Rechnung')
                vehicleSellMenu:AddItem(vehicleSellConfirm)

                local vehicleSellGive = NativeUI.CreateItem('~r~Fahrzeug übergeben', 'Übergebe das Fahrzeug nachdem bezahlt wurde')
                vehicleSellMenu:AddItem(vehicleSellGive)

                local vehicleSellPriceConfirm, vehicleSellVehicle, vehicleSellPlayer = 0, nil, nil
                vehicleSellMenu.OnItemSelect = function(sender, item, index)
                    if item == vehicleSellPrice then
                        local price = CreateDialog('Gebe den Verkaufspreis an')

                        if price and tonumber(price) then
                            vehicleSellPriceConfirm = tonumber(price)
                            vehicleSellPrice:RightLabel('$' .. tostring(MSK.Comma(price)))
                        else
                            Config.Notification(nil, 'Gebe eine gültige Zahl an!', 'error')
                        end
                    elseif item == vehicleSellConfirm then
                        local vehicle, coords = MSK.GetVehicleInDirection()

                        if vehicle and DoesEntityExist(vehicle) then
                            vehicleSellVehicle = vehicle
                            local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                            local plate = GetVehicleNumberPlateText(vehicle)

                            if MSK.TriggerCallback('msk_personalmenu:isOwned', plate) then
                                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()

                                if closestPlayer ~= -1 and closestPlayerDistance <= 2.5 then
                                    vehicleSellPlayer = closestPlayer
                                    local distance = #(GetEntityCoords(PlayerPedId()) - coords)

                                    if distance <= 3.0 then
                                        local reasonStr = ('Fahrzeug: %s, Kennzeichen: %s, Kaufpreis: $%s'):format(vehicleName, plate, MSK.Comma(vehicleSellPriceConfirm))
                                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), nil, reasonStr, vehicleSellPriceConfirm)
                                    end
                                else
                                    Config.Notification(nil, 'Es ist kein Spieler in der Nähe!', 'error')
                                end
                            else
                                Config.Notification(nil, 'Das Fahrzeug mit dem Kennzeichen ' .. plate .. ' gehört dir nicht!', 'error')
                            end
                        else
                            Config.Notification(nil, 'Es ist kein Fahrzeug vor dir!', 'error')
                        end
                    elseif item == vehicleSellGive then
                        TriggerServerEvent('msk_personalmenu:sellVehicle', GetPlayerServerId(PlayerId()), GetPlayerServerId(vehicleSellPlayer), GetVehicleNumberPlateText(vehicleSellVehicle))
                        _menuPool:CloseAllMenus()
                    end
                end

                local vehicleInfo = _menuPool:AddSubMenu(vehicleMenu, 'Fahrzeuginformationen')
                vehicleInfo.ParentItem:RightLabel('→→→')
                setCutomBanner(vehicleInfo, background)
                setVehicleInfos(vehicleInfo, vehicle)
            end
        end
    end
end

setVehicleInfos = function(vehicleInfo, vehicle)
    local vehicleBrand = NativeUI.CreateItem('Marke', '')
    vehicleBrand:RightLabel(GetMakeNameFromVehicleModel(GetEntityModel(vehicle)))
    vehicleInfo:AddItem(vehicleBrand)

    local vehicleLabel = NativeUI.CreateItem('Name', '')
    vehicleLabel:RightLabel(GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))))
    vehicleInfo:AddItem(vehicleLabel)

    local vehiclePlate = NativeUI.CreateItem('Kennzeichen', '')
    vehiclePlate:RightLabel(GetVehicleNumberPlateText(vehicle))
    vehicleInfo:AddItem(vehiclePlate)
end