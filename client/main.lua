local QBCore = exports['qb-core']:GetCoreObject()

local display = false

local function SetDisplay(bool)
    display = bool
    SetNuiFocus(display, display)
    SendNUIMessage({
        type = "ui",
        status = display
    })
    
    if Config.UseBucket then
        local bucketId = bool and GetPlayerServerId(PlayerId()) or 0
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local vehicleNetId = vehicle ~= 0 and NetworkGetNetworkIdFromEntity(vehicle) or nil
        TriggerServerEvent('bar-liveries:setBucket', bucketId, vehicleNetId)
    end
end

local function OpenLiveriesMenu()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        if GetPedInVehicleSeat(vehicle, -1) == ped then
            SetDisplay(true)
            local numLiveries = GetVehicleLiveryCount(vehicle)
            local currentLivery = GetVehicleLivery(vehicle)
            local liveries = {}
            
            if numLiveries > 0 then
                for i = 0, numLiveries - 1 do
                    table.insert(liveries, {
                        id = i,
                        name = "Livery " .. (i + 1),
                        current = (i == currentLivery)
                    })
                end
            end
            
            local extras = {}
            for i = 1, 14 do
                if DoesExtraExist(vehicle, i) then
                    table.insert(extras, {
                        id = i,
                        name = "Extra " .. i,
                        enabled = IsVehicleExtraTurnedOn(vehicle, i)
                    })
                end
            end
            
            SendNUIMessage({
                type = "update",
                liveries = liveries,
                extras = extras
            })
        else
            QBCore.Functions.Notify("You must be the driver", "error")
        end
    else
        QBCore.Functions.Notify("You must be in a vehicle", "error")
    end
end

RegisterCommand('openliveries', OpenLiveriesMenu)

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('changeLivery', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleLivery(vehicle, data.id)
    end
    cb('ok')
end)

RegisterNUICallback('toggleExtra', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 and data.id then
        local currentState = IsVehicleExtraTurnedOn(vehicle, data.id)
        local desiredState = data.enabled
        
        if (currentState == 1 or currentState == true) ~= desiredState then
            local setExtraValue = not desiredState
            
            SetVehicleExtra(vehicle, data.id, setExtraValue)
            Wait(50)
            
            local newState = IsVehicleExtraTurnedOn(vehicle, data.id)
            
            SetTimeout(100, function()
                local numLiveries = GetVehicleLiveryCount(vehicle)
                local currentLivery = GetVehicleLivery(vehicle)
                local liveries = {}
                
                if numLiveries > 0 then
                    for i = 0, numLiveries - 1 do
                        table.insert(liveries, {
                            id = i,
                            name = "Livery " .. (i + 1),
                            current = (i == currentLivery)
                        })
                    end
                end

                local extras = {}
                for i = 1, 14 do
                    if DoesExtraExist(vehicle, i) then
                        local isOn = IsVehicleExtraTurnedOn(vehicle, i)
                        local enabled = isOn == 1 or isOn == true
                        table.insert(extras, {
                            id = i,
                            name = "Extra " .. i,
                            enabled = enabled
                        })
                    end
                end
                
                SendNUIMessage({
                    type = "update",
                    liveries = liveries,
                    extras = extras
                })
            end)
        end
    end
    cb('ok')
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPos = GetEntityCoords(PlayerPedId())
        local distance = #(playerPos - vector3(Config.Locations.MenuTrigger.x, Config.Locations.MenuTrigger.y, Config.Locations.MenuTrigger.z))
        
        if distance < Config.Distances.CheckRange then
            sleep = 0
            if distance < Config.Distances.ShowPrompt then
                lib.showTextUI('Press [E] to Open Livery Menu')
                if IsControlJustPressed(0, 38) then
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                        local pos = Config.Locations.VehiclePosition
                        SetEntityCoords(vehicle, pos.x, pos.y, pos.z, false, false, false, true)
                        SetEntityHeading(vehicle, pos.w)
                        OpenLiveriesMenu()
                    else
                        QBCore.Functions.Notify("You must be in a vehicle and be the driver", "error")
                    end
                end
            else
                lib.hideTextUI()
            end
        end
        Wait(sleep)
    end
end)

SetDisplay(false)
