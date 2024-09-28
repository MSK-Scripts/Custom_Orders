local screenanimation = false
local food = 0
local thirst = 0
StopScreenEffect('ChopVision')

CreateThread(function ()
    while true do
        Wait(Config.Timer)

        CheckStatus()
        Wait(1500)

        if not screenanimation then
            if errorFoodandThirst then 
                sendAdvancedMessage(Locales[Config.Locale]['errorThirstAndFood']) 
                screenAnimationCopper()
            end

            if errorFood then 
                sendAdvancedMessage(Locales[Config.Locale]['errorFood'])
                screenAnimationCopper()
            end

            if errorThirst then 
                sendAdvancedMessage(Locales[Config.Locale]['errorThirst'])
                screenAnimationCopper()
            end

            if informFoodandThirst then sendAdvancedMessage(Locales[Config.Locale]['informThirstAndFood']) end
            if informFood then sendAdvancedMessage(Locales[Config.Locale]['informFood']) end
            if informThirst then sendAdvancedMessage(Locales[Config.Locale]['informThirst']) end
        end
    end
end)

function CheckStatus()
    if Config.Debug then print("[Debug] Checkstatus function") end

    TriggerEvent('esx_status:getStatus', 'hunger', function(statHunger)
        food = statHunger.val / 10000

        TriggerEvent('esx_status:getStatus', 'thirst', function(statThirst)
            thirst = statThirst.val / 10000
    
            if Config.Debug then
                print("Hunger:" .. food)
                print("Thirst:" .. thirst)
            end

            informFoodandThirst, errorFoodandThirst, errorFood, errorThirst, warningFood, warningThirst, informFood, informThirst, noHunger, noThirst = false, false, false, false, false, false, false, false, false, false

            if (food >= Config.FoodMinError and food <= Config.FoodMaxError) and (thirst >= Config.DrinkMinError and thirst <= Config.DrinkMaxError) then
                errorFoodandThirst = true
                return
            elseif (food >= Config.FoodMinInform and food <= Config.FoodMaxInform) and (thirst >= Config.DrinkMinInform and thirst <= Config.DrinkMaxInform) then
                informFoodandThirst = true
                return
            end
    
            if (food < Config.FoodMaxError) then warningFood = true end
            if (thirst < Config.DrinkMaxError) then warningThirst = true end
            if (food >= Config.FoodMinError and food <= Config.FoodMaxError) then errorFood = true end
            if (food >= Config.FoodMinInform and food <= Config.FoodMaxInform) then informFood = true end
            if (thirst >= Config.DrinkMinError and thirst <= Config.DrinkMaxError) then errorThirst = true end
            if (thirst >= Config.DrinkMinInform and thirst <= Config.DrinkMaxInform) then informThirst = true end   
        end)
    end)
end

function screenAnimationCopper()
    if Config.Debug then print("[Debug] screenAnitmationCopper") end

    StartScreenEffect('ChopVision', 6000, true)
    screenanimation = true
    local warningMessage = 0
    
    if Config.Debug then print("[Debug] Screenanimation activated") end

    while true do
        CheckStatus()
        Wait(Config.repeatMessageAfter)
        if Config.Debug then print("[Debug] Repating warning message. Counter to message: " .. warningMessage .. "/6") end

        if warningThirst and warningFood then
            if warningMessage == 6 then
                sendAdvancedMessage(Locales[Config.Locale]['warningThirstAndFood'])
                warningMessage = 0
            end   
        elseif warningFood and not warningThirst then
            if warningMessage == 6 then
                sendAdvancedMessage(Locales[Config.Locale]['warningFood'])
                warningMessage = 0
            end
        elseif warningThirst and not warningFood then
            if warningMessage == 6 then
                sendAdvancedMessage(Locales[Config.Locale]['warningThirst'])
                warningMessage = 0
            end
        elseif food > Config.FoodMaxError and thirst > Config.DrinkMaxError then
            if Config.Debug then print("[Debug] Screenanitmation stopped, food and thirst above maxLevel.") end
            StopScreenEffect('ChopVision')
            screenanimation = false
        end
        
        warningMessage = warningMessage + 1 
        if not screenanimation then break end     
    end
end

function sendAdvancedMessage(message)
    if Config.Debug then print("[Debug] sendMessageFunction") end
    if Config.Debug then print("[Debug] sendMessageFunction with name: " .. ESX.PlayerData.name) end

    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
    ESX.ShowAdvancedNotification(ESX.PlayerData.name, 'hunger/thirst', message, mugshotStr, 1)
    UnregisterPedheadshot(mugshot)
end