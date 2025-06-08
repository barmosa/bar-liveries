local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('openliveries', 'Open vehicle livery menu', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('bar-liveries:openMenu', source)
end)

RegisterNetEvent('bar-liveries:setBucket')
AddEventHandler('bar-liveries:setBucket', function(isOpen, vehicleNetId)
    if not Config.UseBucket then return end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local oldBucket = GetPlayerRoutingBucket(src)
    local bucketId = isOpen and src or 0
    
    SetPlayerRoutingBucket(src, bucketId)
    if Config.Debug then
        print(string.format('[Bucket] %s (ID: %s) moved from bucket %s to bucket %s', GetPlayerName(src), src, oldBucket, bucketId))
    end

    if vehicleNetId then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        if vehicle and vehicle ~= 0 then
            SetEntityRoutingBucket(vehicle, bucketId)
            if Config.Debug then
                print(string.format('[Bucket] Vehicle (NetID: %s) moved to bucket %s', vehicleNetId, bucketId))
            end
        end
    end
end)
