if Config.Framework:match('ESX') then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework:match('QBCore') then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterServerEvent('lifeinvader:send')
AddEventHandler('lifeinvader:send', function(text)
    local src = source
    local xPlayer
    local money

    if Config.Framework:match('ESX') then
        xPlayer = ESX.GetPlayerFromId(source)
        money = xPlayer.getAccount('money').money
    elseif Config.Framework:match('QBCore') then
        xPlayer = QBCore.Functions.GetPlayer(source)
        money = xPlayer.PlayerData.money.cash
    else
        return TriggerClientEvent('lifeinvader:sendToAll', -1, text)
    end

    print(money)

    if money >= Config.Price then
        if Config.Framework:match('ESX') then
            xPlayer.removeMoney(Config.Price)
        elseif Config.Framework:match('QBCore') then
            xPlayer.Functions.RemoveMoney('cash', Config.Price)
        end

        TriggerClientEvent('lifeinvader:sendToAll', -1, text)
    else
        if Config.Framework:match('ESX') then
            xPlayer.showNotification('Du hast nicht genügend Geld dabei!')
        elseif Config.Framework:match('QBCore') then
            TriggerClientEvent('QBCore:Notify', src, 'Du hast nicht genügend Geld dabei!', 'primary', 5000)
        end
    end
end)