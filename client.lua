-- Airdrop System - Client Side (ESX)
ESX = exports['es_extended']:getSharedObject()

local activeAirdrops = {}
local airdropBlips = {}
local airdropObjects = {}

-- Request sync on resource start
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('airdrop:requestSync')
end)

-- Handle okokNotify for all players
RegisterNetEvent('airdrop:notifyAll')
AddEventHandler('airdrop:notifyAll', function(type, title, message, duration)
    exports['okokNotify']:Alert(title, message, duration, type)
end)

-- Spawn airdrop event
RegisterNetEvent('airdrop:spawn')
AddEventHandler('airdrop:spawn', function(airdropData)
    local airdropId = airdropData.id
    activeAirdrops[airdropId] = airdropData
    
    -- Create blip
    local blip = AddBlipForCoord(airdropData.coords.x, airdropData.coords.y, airdropData.coords.z)
    SetBlipSprite(blip, 501) -- Crate icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 2) -- Green
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Airdrop #" .. airdropId)
    EndTextCommandSetBlipName(blip)
    
    -- Add blip pulsing effect
    SetBlipFlashes(blip, true)
    
    airdropBlips[airdropId] = blip
    
    -- Spawn the visual object (crate with smoke)
    CreateThread(function()
        -- Request models
        local crateModel = GetHashKey("prop_box_guncase_03a")
        local smokeModel = GetHashKey("prop_air_bigradar")
        local parachuteModel = GetHashKey("p_parachute1_s")
        
        RequestModel(crateModel)
        while not HasModelLoaded(crateModel) do
            Wait(100)
        end
        
        RequestModel(parachuteModel)
        while not HasModelLoaded(parachuteModel) do
            Wait(100)
        end
        
        -- Spawn plane (optional visual effect)
        local planeStart = vector3(airdropData.coords.x - 500.0, airdropData.coords.y - 500.0, airdropData.coords.z + 300.0)
        
        -- Create crate falling from sky
        local crateCoords = vector3(airdropData.coords.x, airdropData.coords.y, airdropData.coords.z + 100.0)
        local crate = CreateObject(crateModel, crateCoords.x, crateCoords.y, crateCoords.z, true, true, true)
        
        SetEntityLodDist(crate, 1000)
        SetEntityVelocity(crate, 0.0, 0.0, -5.0)
        
        -- Spawn parachute above crate
        local parachute = CreateObject(parachuteModel, crateCoords.x, crateCoords.y, crateCoords.z + 5.0, true, true, true)
        AttachEntityToEntity(parachute, crate, 0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        
        -- Wait for crate to land
        while GetEntityHeightAboveGround(crate) > 1.0 do
            Wait(100)
        end
        
        -- Remove parachute
        if DoesEntityExist(parachute) then
            DeleteEntity(parachute)
        end
        
        -- Position crate on ground
        PlaceObjectOnGroundProperly(crate)
        FreezeEntityPosition(crate, true)
        
        -- Add smoke effect
        local groundCoords = GetEntityCoords(crate)
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(100)
        end
        
        UseParticleFxAssetNextCall("core")
        local smoke = StartParticleFxLoopedAtCoord("exp_grd_grenade_smoke", groundCoords.x, groundCoords.y, groundCoords.z + 0.5, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
        
        airdropObjects[airdropId] = {
            crate = crate,
            smoke = smoke,
            coords = groundCoords
        }
        
        SetModelAsNoLongerNeeded(crateModel)
        SetModelAsNoLongerNeeded(parachuteModel)
    end)
end)

-- Remove airdrop event
RegisterNetEvent('airdrop:remove')
AddEventHandler('airdrop:remove', function(airdropId)
    -- Remove blip
    if airdropBlips[airdropId] then
        RemoveBlip(airdropBlips[airdropId])
        airdropBlips[airdropId] = nil
    end
    
    -- Remove objects
    if airdropObjects[airdropId] then
        if DoesEntityExist(airdropObjects[airdropId].crate) then
            DeleteEntity(airdropObjects[airdropId].crate)
        end
        if airdropObjects[airdropId].smoke then
            StopParticleFxLooped(airdropObjects[airdropId].smoke, 0)
        end
        airdropObjects[airdropId] = nil
    end
    
    activeAirdrops[airdropId] = nil
end)

-- Main thread for drawing markers and handling interaction
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for airdropId, airdrop in pairs(activeAirdrops) do
            if airdropObjects[airdropId] and airdropObjects[airdropId].coords then
                local coords = airdropObjects[airdropId].coords
                local distance = #(playerCoords - coords)
                
                if distance < 50.0 then
                    sleep = 0
                    
                    -- Draw marker
                    DrawMarker(
                        1, -- Cylinder marker
                        coords.x, coords.y, coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        2.0, 2.0, 1.0,
                        0, 255, 0, 100,
                        false, true, 2, false, nil, nil, false
                    )
                    
                    -- Show 3D text
                    if distance < 5.0 then
                        Draw3DText(coords.x, coords.y, coords.z + 1.0, "[~g~E~w~] Collect Airdrop")
                        
                        -- Check for key press
                        if IsControlJustReleased(0, 38) then -- E key
                            TriggerServerEvent('airdrop:collect', airdropId)
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Function to draw 3D text
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px, py, pz) - vector3(x, y, z))
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Remove all blips
        for _, blip in pairs(airdropBlips) do
            RemoveBlip(blip)
        end
        
        -- Remove all objects
        for _, obj in pairs(airdropObjects) do
            if DoesEntityExist(obj.crate) then
                DeleteEntity(obj.crate)
            end
            if obj.smoke then
                StopParticleFxLooped(obj.smoke, 0)
            end
        end
    end
end)
