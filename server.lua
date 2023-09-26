local QBCore = exports['qbx-core']:GetCoreObject()
local players_keys = {}
pb.locale()

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler("baseevents:enteredVehicle", function(targetVehicle, vehicleSeat, vehicleDisplayName)
    TriggerClientEvent("pb-vehiclekeys:tryingToEnterVehicle", source, targetVehicle, vehicleSeat)
end)

RegisterNetEvent('entityCreated')
AddEventHandler('entityCreated', function(entity)
    local entityType = GetEntityType(entity)

    if entityType ~= 2 then return end

    SetVehicleDoorsLocked(entity, 2)
end)

pb.callback.register('pb-vehiclekeys:AddPlayerKeyServer', function(source, plate, id)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    if not players_keys[citizenid] then players_keys[citizenid] = {} end
    players_keys[citizenid][plate] = true
    if id then lib.callback.await('pb-vehiclekeys:GivePlayerKey', id, plate) end 
    return
end)

pb.callback.register('pb-vehiclekeys:GetCsnKeys', function(source)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid

    if not players_keys[citizenid] then return {} else return players_keys[citizenid] end
end)
