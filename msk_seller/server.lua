RegisterServerEvent('msk_seller:sellItem')
AddEventHandler('msk_seller:sellItem', function(itemName, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local hasItem = xPlayer.hasItem(itemName)

    if hasItem and hasItem.count > amount then
        xPlayer.removeInventoryItem(itemName, amount)
        xPlayer.addAccountMoney('money', amount * Config.Locations[itemName].price)
        xPlayer.showNotification(('Du hast erfolgreich %s %s verkauft'):format(amount, hasItem.label))
    else
        xPlayer.showNotification('Du hast nicht genug davon dabei!')
    end
end)