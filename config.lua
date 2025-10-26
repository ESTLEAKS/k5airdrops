return {
    -- Auto spawn settings
    AutoSpawn = true, -- Set to false to disable automatic spawning
    AirdropsPerInterval = 4, -- Number of airdrops to spawn each interval
    SpawnInterval = 600000, -- Time between auto spawns in milliseconds (600000 = 10 minutes)
    
    -- Item settings
    MinItemsPerDrop = 3, -- Minimum items per airdrop
    MaxItemsPerDrop = 6, -- Maximum items per airdrop
    
    -- Authorized players (Add FiveM identifiers here)
    -- You can use: steam:, license:, discord:, fivem:, etc.
    AuthorizedPlayers = {
        "steam:110000103fd1bb1", -- Example Steam ID
        "license:a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8", -- Example License
        "discord:123456789012345678", -- Example Discord ID
        -- Add more authorized players below:
        
    },
    
    -- Drop locations (Add as many as you want)
    DropLocations = {
        -- Los Santos City
        {x = 215.72, y = -810.12, z = 30.73}, -- Legion Square
        {x = -265.71, y = -957.37, z = 31.22}, -- Maze Bank Arena
        {x = 129.84, y = -1299.71, z = 29.27}, -- Strawberry Ave
        {x = -1037.44, y = -2736.69, z = 20.17}, -- Airport
        {x = 1207.52, y = -1402.74, z = 35.22}, -- El Rancho Blvd
        
        -- Sandy Shores
        {x = 1692.39, y = 3585.88, z = 35.62}, -- Sandy Shores Center
        {x = 1961.29, y = 3740.52, z = 32.34}, -- Sandy Shores Airfield
        {x = 2441.29, y = 4068.52, z = 38.07}, -- Grapeseed
        
        -- Paleto Bay
        {x = -386.52, y = 6046.33, z = 31.50}, -- Paleto Bay Center
        {x = -105.82, y = 6528.49, z = 29.88}, -- Paleto Cove
        
        -- Wilderness Areas
        {x = -1158.52, y = 4926.84, z = 222.31}, -- Chiliad Mountain
        {x = 2561.23, y = 2603.17, z = 38.09}, -- Alamo Sea
        {x = 738.29, y = 4170.20, z = 40.71}, -- Grapeseed Fields
        {x = -1475.23, y = 4996.34, z = 63.49}, -- North Chumash
        {x = 1570.52, y = 2194.73, z = 78.97}, -- Prison Area
        
        -- Beach Areas
        {x = -1291.52, y = -1394.23, z = 4.59}, -- Vespucci Beach
        {x = -1850.52, y = -1248.94, z = 8.62}, -- Del Perro Pier
        
        -- Add your own custom locations here:
        -- {x = 0.0, y = 0.0, z = 0.0}, -- Description
    },
    
    -- Airdrop items (Customize what can be found in airdrops)
    -- name = item spawn name in your database
    -- label = display name for players
    -- minAmount/maxAmount = random amount between these values
    AirdropItems = {
        -- Weapons
        {name = "WEAPON_PISTOL", label = "Pistol", minAmount = 1, maxAmount = 1},
        {name = "WEAPON_ASSAULTRIFLE", label = "Assault Rifle", minAmount = 1, maxAmount = 1},
        {name = "WEAPON_COMBATPISTOL", label = "Combat Pistol", minAmount = 1, maxAmount = 1},
        {name = "WEAPON_SMG", label = "SMG", minAmount = 1, maxAmount = 1},
        
        -- Ammo
        {name = "ammo-9", label = "9mm Ammo", minAmount = 50, maxAmount = 150},
        {name = "ammo-rifle", label = "Rifle Ammo", minAmount = 50, maxAmount = 150},
        {name = "ammo-shotgun", label = "Shotgun Ammo", minAmount = 20, maxAmount = 60},
        
        -- Medical Items
        {name = "bandage", label = "Bandage", minAmount = 5, maxAmount = 15},
        {name = "medikit", label = "Medikit", minAmount = 2, maxAmount = 5},
        
        -- Food & Drink
        {name = "water", label = "Water", minAmount = 3, maxAmount = 10},
        {name = "bread", label = "Bread", minAmount = 3, maxAmount = 10},
        {name = "sandwich", label = "Sandwich", minAmount = 2, maxAmount = 5},
        
        -- Money & Valuables
        {name = "black_money", label = "Dirty Money", minAmount = 5000, maxAmount = 25000},
        {name = "gold", label = "Gold Bar", minAmount = 1, maxAmount = 3},
        {name = "diamond", label = "Diamond", minAmount = 1, maxAmount = 5},
        
        -- Crafting Materials
        {name = "lockpick", label = "Lockpick", minAmount = 2, maxAmount = 5},
        {name = "armor", label = "Body Armor", minAmount = 1, maxAmount = 2},
        {name = "radio", label = "Radio", minAmount = 1, maxAmount = 1},
        
        -- Rare Items
        {name = "phone", label = "Phone", minAmount = 1, maxAmount = 1},
        {name = "backpack", label = "Backpack", minAmount = 1, maxAmount = 1},
        
        -- Add your own custom items here:
        -- {name = "item_name", label = "Display Name", minAmount = 1, maxAmount = 5},
    }
}
