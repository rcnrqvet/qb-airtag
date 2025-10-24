local QBCore = exports['qb-core']:GetCoreObject()
local ActiveTrackers = {} -- [itemId] = { blip, itemId, updateThread, nameUpdateThread }

-- activate tracker with interact
RegisterNetEvent('qb-airtag:client:ActivateTracker', function(item)
    if ActiveTrackers[item.itemId] then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 459)
    SetBlipColour(blip, 69)
    SetBlipScale(blip, 0.9)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Active Airtag - 30 Minutes Left")
    EndTextCommandSetBlipName(blip)

    -- start update thread for this tracker in background
    local updateThread = CreateThread(function()
        while ActiveTrackers[item.itemId] do
            QBCore.Functions.TriggerCallback('qb-airtag:server:FindAirtagLocation', function(result)
                if not result then
                    -- tracker expired or not found
                    print("[Airtag Client] Tracker #"..item.itemId.." returned nil - removing")
                    if ActiveTrackers[item.itemId] then
                        if DoesBlipExist(ActiveTrackers[item.itemId].blip) then
                            RemoveBlip(ActiveTrackers[item.itemId].blip)
                        end
                        ActiveTrackers[item.itemId] = nil
                    end
                end
            end, item.itemId)
            
            Wait(5000) -- update every 5 seconds
        end
    end)

    -- start blip name update thread (updates every 30 seconds)
    local nameUpdateThread = CreateThread(function()
        while ActiveTrackers[item.itemId] do
            QBCore.Functions.TriggerCallback('qb-airtag:server:GetTimeRemaining', function(timeLeft)
                if timeLeft and timeLeft > 0 and ActiveTrackers[item.itemId] then
                    local minutesLeft = math.ceil(timeLeft / 60)
                    local blipToUpdate = ActiveTrackers[item.itemId].blip
                    
                    if DoesBlipExist(blipToUpdate) then
                        BeginTextCommandSetBlipName("STRING")
                        if minutesLeft == 1 then
                            AddTextComponentString("Active Airtag - 1 Minute Left")
                        else
                            AddTextComponentString("Active Airtag - " .. minutesLeft .. " Minutes Left")
                        end
                        EndTextCommandSetBlipName(blipToUpdate)
                    end
                end
            end, item.itemId)
            
            Wait(30000) -- update name every 30 sec
        end
    end)

    ActiveTrackers[item.itemId] = { 
        blip = blip, 
        itemId = item.itemId,
        updateThread = updateThread,
        nameUpdateThread = nameUpdateThread
    }

    print("[Airtag Client] Activated tracker #" .. item.itemId)
end)

-- server requests location check for tha airtag
RegisterNetEvent('qb-airtag:client:RequestLocation', function(itemId)
    local found = false
    local coords = nil
    local locationType = "unknown"

    -- check player inventory for tag
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.items then
        for _, item in pairs(PlayerData.items) do
            if item.name == "airtag" and item.info and item.info.itemId == itemId then
                coords = GetEntityCoords(PlayerPedId())
                locationType = "player inventory"
                found = true
                break
            end
        end
    end

    -- check nearby vehicles for airtag (within 100m)
    if not found then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local vehicles = GetGamePool('CVehicle')
        
        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) then
                local vehCoords = GetEntityCoords(vehicle)
                if #(pedCoords - vehCoords) < 100.0 then
                    -- check vehicle trunk via qb-inventory
                    local plate = QBCore.Functions.GetPlate(vehicle)
                    if plate then
                        -- client wont be able to directly touch inv due to exploit abuse
                        -- so you would have to touch qb-inventory for it to work 
                        -- so we can check for vehicle ownership
                        -- isnt the best but should work
                    end
                end
            end
        end
    end

    -- check dropped items nearby (within 100m)
    if not found then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local objects = GetGamePool('CObject')
        
        for _, obj in ipairs(objects) do
            if DoesEntityExist(obj) then
                local objCoords = GetEntityCoords(obj)
                if #(pedCoords - objCoords) < 100.0 then
                    -- check if this is a dropped item
                    -- qb-inventory spawns dropped items as props
                    local model = GetEntityModel(obj)
                    if model == GetHashKey("prop_micro_01") or model == GetHashKey("prop_ld_case_01") then
                        -- this might be a dropped item, but we can't check info from client
                        -- so we have to mark it as a potential for now
                        coords = objCoords
                        locationType = "dropped item (potential)"
                    end
                end
            end
        end
    end

    -- report back to server if found
    if coords then
        TriggerServerEvent('qb-airtag:server:LocationFound', itemId, coords, locationType)
    end
end)

-- update blip coordinates from server
RegisterNetEvent('qb-airtag:client:UpdateBlip', function(itemId, coords)
    local tracker = ActiveTrackers[itemId]
    if tracker and DoesBlipExist(tracker.blip) and coords then
        SetBlipCoords(tracker.blip, coords.x, coords.y, coords.z)
    end
end)

-- deactivate tracker once called
RegisterNetEvent('qb-airtag:client:DeactivateTracker', function(itemId)
    local tracker = ActiveTrackers[itemId]
    if tracker then
        if DoesBlipExist(tracker.blip) then 
            RemoveBlip(tracker.blip) 
        end
        ActiveTrackers[itemId] = nil
        print("[Airtag Client] Deactivated tracker #" .. itemId)
    end
end)