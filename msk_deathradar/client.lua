local Blips, activeBlips = {}, {}

RegisterNetEvent('msk_deathradar:activateGPS')
AddEventHandler('msk_deathradar:activateGPS', function(GPS)
    addBlip(GPS)
end)

RegisterNetEvent('msk_deathradar:refreshBlips')
AddEventHandler('msk_deathradar:refreshBlips', function(GPS)
    refreshBlips(GPS)
end)

RegisterNetEvent('msk_deathradar:deactivateGPSById')
AddEventHandler('msk_deathradar:deactivateGPSById', function(source)
    removeBlip(source)
end)

addBlip = function(GPS)
    local blip = AddBlipForCoord(GPS.coords.x, GPS.coords.y, GPS.coords.z)

    SetBlipSprite(blip, Config.Blip.id)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.color)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.text)
    EndTextCommandSetBlipName(blip)

    table.insert(Blips, {blip = blip, source = GPS.source})
    activeBlips[GPS.source] = {isActive = false, blip = blip}
end

removeBlip = function(source)
    if not activeBlips[source] then return end

    for k, blip in pairs(Blips) do
        if activeBlips[source].blip == blip then
            table.remove(k)
        end
    end

    RemoveBlip(activeBlips[source].blip)
    activeBlips[source] = nil
end

refreshBlips = function(GPS)
    for playerId, v in pairs(GPS) do
        -- v = source, netId, coords
        local inOneSync = inOneSync(v.netId)
                
        if inOneSync and not activeBlips[playerId].isActive then
            CreateThread(function()
                activeBlips[playerId].isActive = true

                while activeBlips[playerId] and activeBlips[playerId].isActive and DoesEntityExist(inOneSync.ped) do
                    local coords = GetEntityCoords(inOneSync.ped)
                    local heading = math.ceil(GetEntityHeading(inOneSync.ped))

                    SetBlipCoords(activeBlips[playerId].blip, coords.x, coords.y, coords.z)

                    Wait(0)
                end
            end)
        elseif not inOneSync then
            activeBlips[playerId].isActive = false
            SetBlipCoords(activeBlips[playerId].blip, v.coords.x, v.coords.y, v.coords.z)
        end
    end
end

inOneSync = function(netId)
    local playerPed = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId)

    if DoesEntityExist(playerPed) then return {ped = playerPed} end
    return false
end