local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bar-liveries:setBucket')
AddEventHandler('bar-liveries:setBucket', function(bucketId, vehicleNetId)
    if not Config.UseBucket then return end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    SetPlayerRoutingBucket(src, bucketId)

    if vehicleNetId then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        if vehicle and vehicle ~= 0 then
            SetEntityRoutingBucket(vehicle, bucketId)
        end
    end
end)
