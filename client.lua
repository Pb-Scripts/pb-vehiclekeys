local MyVehicleKeys = {}
pb.locale()

------------------
-- Vehicle Lock --
------------------

RegisterNetEvent("pb-vehiclekeys:tryingToEnterVehicle")
AddEventHandler("pb-vehiclekeys:tryingToEnterVehicle", function(targetVehicle, vehicleSeat, vehicleDisplayName)
    local ped = PlayerPedId()
    local plate = GetVehicleNumberPlateText(targetVehicle)

    while not MyVehicleKeys[plate] and GetPedInVehicleSeat(targetVehicle, -1) == PlayerPedId() do
        SetVehicleEngineOn(targetVehicle, false, false, true)
        Wait(0)
    end
end)

RegisterCommand("lockveh", function()
    local veh, _ = pb.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, true)
    if veh ~= 0 and MyVehicleKeys[GetVehicleNumberPlateText(veh)] then
        pb.playAnim('anim@mp_player_intmenu@key_fob@', 'fob_click', 48)
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
    pb.callback.await('pb-vehiclekeys:AddPlayerKeyServer', false, plate, id)
    if not id then MyVehicleKeys[plate] = true end
end

pb.callback.register('pb-vehiclekeys:GivePlayerKey', function(plate) MyVehicleKeys[plate] = true return end)

local function HaveKeys(plate)
    return MyVehicleKeys[plate]
end

RegisterCommand("darchaves", function()
    local coords = GetEntityCoords(PlayerPedId())
    local veh, _ = pb.getClosestVehicle(coords, 5.0, true)
    local ped_id, _ = pb.getClosestPlayer(coords, 5.0, false)
    if veh ~= 0 and ped_id then
        GiveKeys(GetVehicleNumberPlateText(veh), GetPlayerServerId(ped_id))
    end
end)

pb.callback.register('pb-vehiclekeys:adminGetKeys', function() 
    local veh, _ = pb.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, true)
    if veh ~= 0 then
        GiveKeys(GetVehicleNumberPlateText(veh))
    end 
    return 
end)

exports("GiveKeys", GiveKeys)
exports("HaveKeys", HaveKeys)

-----------------------------
-- Logout/Leave Management --
-----------------------------

local function RemoveAllKeys() MyVehicleKeys = {} return end
local function GetAllCSNKeys() MyVehicleKeys = pb.callback.await('pb-vehiclekeys:GetCsnKeys') return end

exports("RemoveAllKeys", RemoveAllKeys)
exports("GetAllCSNKeys", GetAllCSNKeys)

RegisterNetEvent(Config.UnloadEvent, function() RemoveAllKeys() end)

RegisterNetEvent(Config.LoadEvent, function() GetAllCSNKeys() end)

--------------
-- Lockpick --
--------------

