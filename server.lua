-- Airdrop System - Server Side (ESX + okokNotify)
ESX = exports['es_extended']:getSharedObject()

local Config = {}
local activeAirdrops = {}
local airdropIdCounter = 0

-- Load config file
CreateThread(function()
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    if configFile then
        local configFunc = load(configFile)
        if configFunc then
            Config = configFunc()
            print('[AIRDROP] Configuration loaded successfully')
        else
            print('[AIRDROP ERROR] Failed to load config.lua')
        end
    else
        print('[AIRDROP ERROR] config.lua file not found')
    end
end)

-- Function to get a random drop location from config
local function getRandomLocation()
    if Config.DropLocations and #Config.DropLocations > 0 then
        return Config.DropLocations[math.random(1, #Config.DropLocations)]
    end
    print('[AIRDROP ERROR] No drop locations configured!')
    return nil
end

-- Function to generate random items for the airdrop
local function getRandomItems()
    local items = {}
    local itemPool = Config.AirdropItems or {}
    
    if #itemPool == 0 then
        print('[AIRDROP ERROR] No items configured in AirdropItems!')
        return items
    end
    
    -- Get random number of items between min and max
    local minItems = Config.MinItemsPerDrop or 3
    local maxItems = Config.MaxItemsPerDrop or 6
    local numItems = math.random(minItems, maxItems)
    
    -- Select random items from pool
    for i = 1, numItems do
        local randomItem = itemPool[math.random(1, #itemPool)]
        table.insert(items, {
            name = randomItem.name,
            label = randomItem.label,
            amount = math.random(randomItem.minAmount, randomItem.maxAmount)
        })
    end
    
    return items
end

-- Function to spawn a single airdrop
local function spawnAirdrop()
    local location = getRandomLocation()
    if not location then
        return nil
    end
    
    airdropIdCounter = airdropIdCounter + 1
    local airdropId = airdropIdCounter
    
    local airdropData = {
        id = airdropId,
        coords = location,
        items = getRandomItems(),
        active = true,
        claimed = false,
        spawnTime = os.time()
    }
    
    activeAirdrops[airdropId] = airdropData
    
    -- Send spawn event to all clients
    TriggerClientEvent('airdrop:spawn', -1, airdropData)
    
    -- Send notification to all players using okokNotify
    TriggerClientEvent('airdrop:notifyAll', -1, 'info', 'Airdrop System', 'An airdrop is incoming! Check your map.', 5000)
    
    print(string.format('[AIRDROP] Spawned airdrop #%d at X:%.2f Y:%.2f Z:%.2f', 
        airdropId, location.x, location.y, location.z))
    
    return airdropId
end

-- Function to spawn multiple airdrops
local function spawnMultipleAirdrops(count)
    if count > 10 then
        count = 10 -- Maximum 10 airdrops at once
    end
    
    local spawnedIds = {}
    
    for i = 1, count do
        local id = spawnAirdrop()
        if id then
            table.insert(spawnedIds, id)
        end
        Wait(500) -- Small delay between each spawn
    end
    
    return spawnedIds
end

-- Auto-spawn airdrops thread
CreateThread(function()
    -- Wait for config to load
    Wait(5000)
    
    if not Config.AutoSpawn then
        print('[AIRDROP] Auto-spawn is disabled in config')
        return
    end
    
    print('[AIRDROP] Auto-spawn enabled - spawning every ' .. (Config.SpawnInterval / 60000) .. ' minutes')
    
    while true do
        local count = Config.AirdropsPerInterval or 4
        
        print(string.format('[AIRDROP] Auto-spawning %d airdrop(s)...', count))
        spawnMultipleAirdrops(count)
        
        -- Wait for the configured interval (default: 10 minutes)
        Wait(Config.SpawnInterval or 600000)
    end
end)

-- Check if player is authorized to use airdrop command
local function isPlayerAuthorized(src)
    if src == 0 then
        return true -- Console always authorized
    end
    
    local playerIdentifiers = GetPlayerIdentifiers(src)
    
    if not Config.AuthorizedPlayers then
        print('[AIRDROP ERROR] No authorized players configured!')
        return false
    end
    
    for _, identifier in ipairs(playerIdentifiers) do
        for _, authorizedId in ipairs(Config.AuthorizedPlayers) do
            if identifier == authorizedId then
                return true
            end
        end
    end
    
    return false
end

-- Command to manually spawn airdrops (Staff only)
RegisterCommand('airdrop', function(source, args, rawCommand)
    local src = source
    
    -- Check authorization
    if not isPlayerAuthorized(src) then
        if src ~= 0 then
            exports['okokNotify']:Alert(src, 'Airdrop System', 'You don\'t have permission to use this command!', 5000, 'error')
        end
        return
    end
    
    -- Get count from arguments (default 1)
    local count = tonumber(args[1]) or 1
    
    if count < 1 then
        count = 1
    elseif count > 10 then
        count = 10 -- Maximum 10
    end
    
    -- Spawn the airdrops
    local spawnedIds = spawnMultipleAirdrops(count)
    
    -- Send confirmation
    if src == 0 then
        print(string.format('[AIRDROP] Console spawned %d airdrop(s)', count))
    else
        exports['okokNotify']:Alert(src, 'Airdrop System', string.format('Successfully spawned %d airdrop(s)!', count), 5000, 'success')
        print(string.format('[AIRDROP] %s spawned %d airdrop(s)', GetPlayerName(src), count))
    end
end, false)

-- Handle airdrop collection
RegisterNetEvent('airdrop:collect')
AddEventHandler('airdrop:collect', function(airdropId)
    local src = source
    
    -- Validate airdrop exists
    if not activeAirdrops[airdropId] then
        exports['okokNotify']:Alert(src, 'Airdrop System', 'This airdrop no longer exists!', 5000, 'error')
        return
    end
    
    -- Check if already claimed
    if activeAirdrops[airdropId].claimed then
        exports['okokNotify']:Alert(src, 'Airdrop System', 'This airdrop has already been claimed!', 5000, 'error')
        return
    end
    
    -- Mark as claimed
    activeAirdrops[airdropId].claimed = true
    activeAirdrops[airdropId].claimedBy = GetPlayerName(src)
    activeAirdrops[airdropId].claimTime = os.time()
    
    -- Get player's ESX data
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        print('[AIRDROP ERROR] Could not get ESX player data for ID: ' .. src)
        return
    end
    
    -- Give items to player
    local items = activeAirdrops[airdropId].items
    local itemsList = ""
    local itemCount = 0
    
    for i, item in ipairs(items) do
        -- Add item to player inventory
        xPlayer.addInventoryItem(item.name, item.amount)
        
        -- Build items list for notification
        itemCount = itemCount + 1
        itemsList = itemsList .. item.amount .. "x " .. item.label
        
        if i < #items then
            itemsList = itemsList .. ", "
        end
        
        print(string.format('[AIRDROP] Gave %s %dx %s', GetPlayerName(src), item.amount, item.name))
    end
    
    -- Send success notification
    exports['okokNotify']:Alert(src, 'Airdrop Collected!', 'You received: ' .. itemsList, 7000, 'success')
    
    -- Remove airdrop from clients
    TriggerClientEvent('airdrop:remove', -1, airdropId)
    
    print(string.format('[AIRDROP] Player %s collected airdrop #%d containing %d items', 
        GetPlayerName(src), airdropId, itemCount))
    
    -- Clean up after 10 seconds
    SetTimeout(10000, function()
        activeAirdrops[airdropId] = nil
    end)
end)

-- Sync active airdrops with newly connected players
RegisterNetEvent('airdrop:requestSync')
AddEventHandler('airdrop:requestSync', function()
    local src = source
    
    for airdropId, airdrop in pairs(activeAirdrops) do
        if airdrop.active and not airdrop.claimed then
            TriggerClientEvent('airdrop:spawn', src, airdrop)
        end
    end
    
    print(string.format('[AIRDROP] Synced %d active airdrops with player %s', 
        #activeAirdrops, GetPlayerName(src)))
end)

-- Command to list active airdrops (for debugging/staff)
RegisterCommand('airdrops', function(source, args, rawCommand)
    local src = source
    
    if not isPlayerAuthorized(src) then
        if src ~= 0 then
            exports['okokNotify']:Alert(src, 'Airdrop System', 'You don\'t have permission to use this command!', 5000, 'error')
        end
        return
    end
    
    local activeCount = 0
    local claimedCount = 0
    
    for _, airdrop in pairs(activeAirdrops) do
        if airdrop.claimed then
            claimedCount = claimedCount + 1
        else
            activeCount = activeCount + 1
        end
    end
    
    if src == 0 then
        print(string.format('[AIRDROP] Active: %d | Claimed: %d | Total: %d', 
            activeCount, claimedCount, activeCount + claimedCount))
    else
        exports['okokNotify']:Alert(src, 'Airdrop Status', 
            string.format('Active: %d | Claimed: %d', activeCount, claimedCount), 5000, 'info')
    end
end, false)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('[AIRDROP] Resource stopped - cleaning up ' .. #activeAirdrops .. ' active airdrops')
        activeAirdrops = {}
    end
end)
