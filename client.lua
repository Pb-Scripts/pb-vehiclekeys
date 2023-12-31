local MyVehicleKeys = {}
local QBCore = exports['qbx-core']:GetCoreObject()

------------------
-- Vehicle Lock --
------------------

lib.locale()

local function playAnim(dict, anim, flag, time, stopOnly)
    local ped = PlayerPedId()
    while (not HasAnimDictLoaded(dict)) do RequestAnimDict(dict) Wait(0) end
    TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flag, 0, 0, 0, 0)
    if time then Wait(time) 
        if stopOnly then
            StopAnimTask(ped, dict, anim, 500) 
        else
            ClearPedTasks(ped)
        end
    end
    return
end

RegisterNetEvent("pb-vehiclekeys:tryingToEnterVehicle")
AddEventHandler("pb-vehiclekeys:tryingToEnterVehicle", function(targetVehicle, vehicleSeat, vehicleDisplayName)
    local ped = PlayerPedId()
    local plate = GetVehicleNumberPlateText(targetVehicle)

    isShared(targetVehicle)

    while not MyVehicleKeys[plate] and GetPedInVehicleSeat(targetVehicle, -1) == PlayerPedId() do
        SetVehicleEngineOn(targetVehicle, false, false, true)
        Wait(0)
    end
end)

RegisterCommand("lockveh", function()
    local veh, _ = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, true)
    if (veh ~= 0 and MyVehicleKeys[GetVehicleNumberPlateText(veh)]) or isShared(veh) then
        playAnim('anim@mp_player_intmenu@key_fob@', 'fob_click', 48)
        if GetVehicleDoorLockStatus(veh) ~= 0 then
            SetVehicleDoorsLocked(veh, 0)
        else
            SetVehicleDoorsLocked(veh, 2)
        end
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
        SetVehicleLights(veh, 2)
        Wait(250)
        SetVehicleLights(veh, 1)
        Wait(200)
        SetVehicleLights(veh, 0)
    end
end)
RegisterKeyMapping("lockveh", locale("lock_unlock_command"), 'keyboard', "L")

------------
-- Engine --
------------

RegisterCommand("engine", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if GetPedInVehicleSeat(veh, -1) == ped and MyVehicleKeys[GetVehicleNumberPlateText(veh)] then
        local engine = GetIsVehicleEngineRunning(veh)
        if not engine then
            SetVehicleEngineOn(veh, true, false, true)
        else
            SetVehicleEngineOn(veh, false, false, true)
        end
    end
end)
RegisterKeyMapping("engine", locale("engine_command"), 'keyboard', "G")

--------------------
-- Key Management --
--------------------

local function GiveKeys(plate, id)
    lib.callback.await('pb-vehiclekeys:AddPlayerKeyServer', false, plate, id)
    if not id then MyVehicleKeys[plate] = true end
end

lib.callback.register('pb-vehiclekeys:GivePlayerKey', function(plate) MyVehicleKeys[plate] = true return end)

local function HaveKeys(plate)
    return MyVehicleKeys[plate]
end

RegisterCommand("darchaves", function()
    local coords = GetEntityCoords(PlayerPedId())
    local veh, _ = lib.getClosestVehicle(coords, 5.0, true)
    local ped_id, _ = lib.getClosestPlayer(coords, 5.0, false)
    if veh ~= 0 and ped_id then
        GiveKeys(GetVehicleNumberPlateText(veh), GetPlayerServerId(ped_id))
    end
end)

lib.callback.register('pb-vehiclekeys:adminGetKeys', function() 
    local veh, _ = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, true)
    if veh ~= 0 then
        GiveKeys(GetVehicleNumberPlateText(veh))
    end 
    return 
end)

RegisterNetEvent("vehiclekeys:client:SetOwner")
AddEventHandler("vehiclekeys:client:SetOwner", function(plate)
    GiveKeys(plate)
end)

exports("GiveKeys", GiveKeys)
exports("HaveKeys", HaveKeys)

-----------------------------
-- Logout/Leave Management --
-----------------------------

local function RemoveAllKeys() MyVehicleKeys = {} return end
local function GetAllCSNKeys() MyVehicleKeys = lib.callback.await('pb-vehiclekeys:GetCsnKeys') return end

exports("RemoveAllKeys", RemoveAllKeys)
exports("GetAllCSNKeys", GetAllCSNKeys)

RegisterNetEvent(Config.UnloadEvent, function() RemoveAllKeys() end)

RegisterNetEvent(Config.LoadEvent, function() GetAllCSNKeys() end)

--------------
-- Lockpick --
--------------

local function GetVehicleKeysNearby()
    local ped = PlayerPedId()
    local veh, _ = lib.getClosestVehicle(GetEntityCoords(ped), 5.0, true)
    local plate = GetVehicleNumberPlateText(veh)
    GiveKeys(plate)
    return veh
end
exports("GetVehicleKeysNearby", GetVehicleKeysNearby)

local function Lockpicking()
    local ped = PlayerPedId()
    local veh = lib.getClosestVehicle(GetEntityCoords(ped), 5.0, true)
    if IsPedInAnyVehicle(ped, true) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped), -1) == ped then
        GetVehicleKeysNearby()
        playAnim('veh@std@ds@base', 'hotwire', 1, 5000)
    else
        playAnim('anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1, 5000)
        SetVehicleDoorsLocked(veh, 0)
    end
end
exports("Lockpicking", Lockpicking)

-------------
-- Sharing --
-------------

function isShared(veh)
    local jobName = QBCore.Functions.GetPlayerData().job.name
    if Config.Shared[jobName] and veh ~= 0 and not MyVehicleKeys[GetVehicleNumberPlateText(veh)] then
        local vehName = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
        for _, car in pairs(Config.Shared[jobName]) do
            if string.lower(car) == string.lower(vehName) then
                GiveKeys(GetVehicleNumberPlateText(veh))
                return true
            end
        end
    end
    return false
end
