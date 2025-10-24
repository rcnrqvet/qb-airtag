local QBCore = exports['qb-core']:GetCoreObject()
local ActiveTrackers = {} -- [itemId] = { owner = playerId, expire = timestamp }

-- activate airtag
QBCore.Functions.CreateUseableItem("airtag", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if item.info and item.info.activated then
        TriggerClientEvent('swt_notifications:Negative', source, "Airtag Already Active", "You already have a tracker running.", "top-right", 3000, true)
        print("[Airtag] Player "..source.." tried to activate an already active Airtag.")
        return
    end

    local updatedInfo = item.info or {}
    updatedInfo.activated = true
    updatedInfo.itemId = item.info and item.info.itemId or math.random(111111,999999)
    updatedInfo.activatedBy = Player.PlayerData.citizenid

    Player.Functions.RemoveItem(item.name, 1, item.slot)
    Player.Functions.AddItem(item.name, 1, false, updatedInfo)

    ActiveTrackers[updatedInfo.itemId] = {
        owner = source,
        citizenid = Player.PlayerData.citizenid,
        expire = os.time() + 1800 -- should be 30 minutes
    }

    print("[Airtag] Player "..source.." activated Airtag with ID "..updatedInfo.itemId.." (expires at "..os.date("%H:%M:%S", ActiveTrackers[updatedInfo.itemId].expire)..")")
    TriggerClientEvent('qb-airtag:client:ActivateTracker', source, updatedInfo)
    TriggerClientEvent('swt_notifications:Success', source, "Airtag Activated", "Tracking has started successfully.", "top-right", 3000, true)
end)

-- convert airtag to the dead one
local function ConvertAirtagToDead(itemId, citizenid)
    -- check all players for the airtag
    for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local foundSlot = nil
            for slot, invItem in pairs(Player.PlayerData.items) do
                if invItem.name == "airtag" and invItem.info and invItem.info.itemId == itemId then
                    foundSlot = slot
                    print("[Airtag] Found airtag #"..itemId.." in player "..playerId.." inventory (slot "..slot..")")
                    break
                end
            end

            if foundSlot then
                Player.Functions.RemoveItem('airtag', 1, foundSlot)
                Player.Functions.AddItem('deadairtag', 1)
                TriggerClientEvent('inventory:client:ItemBox', playerId, QBCore.Shared.Items['deadairtag'], 'add')
                TriggerClientEvent('swt_notifications:Warning', playerId, "Airtag Expired", "This Airtag is no longer active.", "top-right", 4000, true)
                print("[Airtag] Converted airtag #"..itemId.." to deadairtag for player "..playerId)
                return true
            end
        end
    end
    
    print("[Airtag] Could not find airtag #"..itemId.." in any player inventory (may be dropped/in vehicle)")
    return false
end

-- check for the remaining time left on it
QBCore.Functions.CreateCallback('qb-airtag:server:GetTimeRemaining', function(source, cb, itemId)
    local tracker = ActiveTrackers[itemId]
    if not tracker then 
        cb(0)
        return 
    end
    
    local timeLeft = tracker.expire - os.time()
    cb(math.max(0, timeLeft))
end)

-- client callback for the location
QBCore.Functions.CreateCallback('qb-airtag:server:FindAirtagLocation', function(source, cb, itemId)
    local tracker = ActiveTrackers[itemId]
    if not tracker then 
        print("[Airtag] Tracker #"..itemId.." not found in ActiveTrackers")
        cb(nil)
        return 
    end

    -- expire check
    if os.time() >= tracker.expire then
        print("[Airtag] Tracker #"..itemId.." has expired! Current time: "..os.time()..", Expire time: "..tracker.expire)
        
        -- if dead then convert
        ConvertAirtagToDead(itemId, tracker.citizenid)
        
        -- send the noti that the battery died
        TriggerClientEvent('qb-airtag:client:DeactivateTracker', tracker.owner, itemId)
        
        ActiveTrackers[itemId] = nil
        cb(nil)
        return
    end

    -- pull the location from all clients
    TriggerClientEvent('qb-airtag:client:RequestLocation', -1, itemId)
    
    cb(true) -- ^^
end)

-- saves location
RegisterNetEvent('qb-airtag:server:LocationFound', function(itemId, coords, locationType)
    local tracker = ActiveTrackers[itemId]
    if not tracker then return end

    -- send location only to the owner
    TriggerClientEvent('qb-airtag:client:UpdateBlip', tracker.owner, itemId, coords)
    -- only print every 10th update to reduce spam in console (txadmin)
    if math.random(1, 10) == 1 then
        print(("[Airtag] ID %d found at %s - vec3(%f, %f, %f)"):format(itemId, locationType, coords.x, coords.y, coords.z))
    end
end)

-- player disconnect - clean up their airtags
AddEventHandler('playerDropped', function()
    local src = source
    for itemId, tracker in pairs(ActiveTrackers) do
        if tracker.owner == src then
            ActiveTrackers[itemId] = nil
            print("[Airtag] Removed tracker "..itemId.." (owner disconnected)")
        end
    end
end)

-- check if its supposed to have battery (30 secs)
CreateThread(function()
    while true do
        Wait(30000) -- 30 secs
        local currentTime = os.time()
        
        for itemId, tracker in pairs(ActiveTrackers) do
            if currentTime >= tracker.expire then
                print("[Airtag] ID "..itemId.." has expired in periodic check! Current: "..currentTime..", Expire: "..tracker.expire)
                
                -- try to convert to "deadairtag" item
                ConvertAirtagToDead(itemId, tracker.citizenid)
                
                -- send the notification if owner still active
                local Player = QBCore.Functions.GetPlayer(tracker.owner)
                if Player then
                    TriggerClientEvent('qb-airtag:client:DeactivateTracker', tracker.owner, itemId)
                end
                
                ActiveTrackers[itemId] = nil
            end
        end
    end
end)