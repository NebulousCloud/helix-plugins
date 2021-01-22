local PLUGIN = PLUGIN;
-- I think this is okay.
ix = ix or {};
ix.Scavenging = ix.Scavenging or {};
ix.Scavenging.InformationTables = ix.Scavenging.InformationTables or {};

--[[
    Most functions are generally done in top-down order:
    CanUse -> CanScavenge -> PerformScavenge

    Templates have been added to give a summary of what functions do.
]]

--[[
    If you don't know how Chance works, it adds up all the Chance as a total number.
    That total number is used to divide a specific item's Chance to determine it's odds.

    For example, Item 1 with Chance 4 and Item 2 with Chance 1 would equal to a total of Chance 5.
    Item 1 would have a 80% chance or "4/5" chance.
    Item 2 would have a 20% chance or "1/5" chance.
]]

ix.Scavenging.InformationTables["Blank Template"] = { -- Example #1: Blank Template.
    ["Display Name"] = "Blank Template",
    ["Display Description"] = "A template with the barest bones of functions and returns.",
    ["StartingModel"] = "models/hunter/blocks/cube025x025x025.mdl",
    ["Inventory Width"] = 2,
    ["Inventory Height"] = 2,
    ["CanUse"] = function( client, character, entity )
        --[[
            nil     return entity:CanUse();
            false   return;
            string  return & client:Notify();
            true    return true;
        ]]
        return nil;
    end,
    ["CanScavenge"] = function( client, character, entity )
        --[[
            nil     ShouldScavenge = entity:CanScavenge();
            false   ShouldScavenge = false;
            string  ShouldScavenge = false & client:Notify();
            true    ShouldScavenge = true;
        ]]
        return nil;
    end,
    ["PerformScavenge"] = function( client, character, entity, ShouldScavenge )
       --[[
           This is only called when ShouldScavenge = true.
           This is called before ix.storage.Open().
           
           WARNING: This will replace the spawning of items if included in the table.
       ]]
        return;
    end,
    ["Usage Message"] = function( client, character, entity, ShouldScavenge )
        --[[
            string  Name for ix.storage.Open().
        ]]
        if( ShouldScavenge ) then
            return "PerformScavenge & Opening Inventory...";
        end
        return "Opening Inventory...";
    end,
    ["Amount of Spawned Items"] = function( client, character, entity )
        --[[
            number  Spawns this many items.
        ]]
        return 1;
    end,
    ["Amount of Spawned Credits"] = function( client, character, entity )
        --[[
            number  Adds this amount of credits.
        ]]
        return 0;
    end,
    ["Possible Items"] = function( client, character, entity )
        --[[
            table  Information about Possible Items.
        ]]
        local Items = { 
            [1] = {
                ["ItemID"] = "water",
                ["Data"] = {},
                ["Chance"] = 3
            },
            [2] = {
                ["ItemID"] = "request_device",
                ["Data"] = {},
                ["Chance"] = 1
            }
        };
        return Items;
    end
};

ix.Scavenging.InformationTables["Default Template"] = { -- Example #2: Default Template.
    ["Display Name"] = "Template With Default/Expected Results",
    ["Display Description"] = "A template that returns results that would typically occur by default.",
    ["StartingModel"] = "models/hunter/blocks/cube025x025x025.mdl",
    ["Inventory Width"] = 2,
    ["Inventory Height"] = 2,
    ["CanUse"] = function( client, character, entity )
        return true;
    end,
    ["CanScavenge"] = function( client, character, entity )
        if( !PLUGIN:GetScavengingEnabled() ) then
            return "Scavenging is currently disabled.";
        end
        if( table.Count( player.GetAll() ) < PLUGIN:GetScavengingPlayerMinimum() ) then
            return "There is not enough players on.";
        end
        if( entity:GetRemainingCooldown() != 0 ) then
            return "Try again in " .. tostring( entity:GetRemainingCooldown() ) .. " seconds.";
        end
        if( !character:GetInventory():HasItem( "scavengingkit" ) ) then
            return "You don't have a scavenging kit.";
        end
        return true;
    end,
    ["PerformScavenge"] = function( client, character, entity, ShouldScavenge )
        -- Variables:
        local tabl = ix.Scavenging.InformationTables[entity:GetTableName()];
        local SItems = tabl["Amount of Spawned Items"]( client, character, entity );
        local SCredits = tabl["Amount of Spawned Credits"]( character, character, entity );
        local PItems = tabl["Possible Items"]( character, character, entity );
        local ItemsToSpawn = {};
        local PossibleItems = {};
        -- Compiling:
        for _, info in pairs( PItems ) do
            local ItemID = info["ItemID"];
            local Data = info["Data"] or {};
            local Chance = info["Chance"] or 1;
            for i = 1, Chance do
                local Next = table.Count( PossibleItems ) + 1;
                PossibleItems[Next] = {
                    ["ItemID"] = ItemID,
                    ["Data"] = Data,
                };
            end
        end
        -- Randomly Selecting:
        for i = 1, SItems do
            local Next = table.Count( ItemsToSpawn ) + 1;
            local Selected = table.Random( PossibleItems );
            ItemsToSpawn[Next] = Selected;
        end
        -- Spawning:
        for _, info in pairs( ItemsToSpawn ) do
            if( !entity:GetInventory():Add( info["ItemID"], 1, info["Data"] ) ) then
                local item = ix.item.Spawn( info["ItemID"], entity:GetPos(), nil, nil, info["Data"] );
            end
        end
        if( SCredits and ix.util.GetTypeFromValue( SCredits ) == ix.type.number and math.max( 0, entity:GetMoney() + SCredits ) != 0 ) then
            entity:SetMoney( entity:GetMoney() + SCredits );
        end
        entity:SetRemainingCooldown( PLUGIN:GetScavengingCooldown() );
        return;
    end,
    ["Usage Message"] = function( client, character, entity, ShouldScavenge )
        if( ShouldScavenge ) then
            return "Scavenging...";
        end
        return "Checking...";
    end,
    ["Amount of Spawned Items"] = function( client, character, entity )
        return 1;
    end,
    ["Amount of Spawned Credits"] = function( client, character, entity )
        return 0;
    end,
    ["Possible Items"] = function( client, character, entity )
        local Items = { 
            [1] = {
                ["ItemID"] = "water",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [2] = {
                ["ItemID"] = "request_device",
                ["Data"] = {},
                ["Chance"] = 1
            }
        };
        return Items;
    end
};

ix.Scavenging.InformationTables["Blank Template"] = nil;
ix.Scavenging.InformationTables["Default Template"] = nil;

--[[
    Examples have been added to give a general understanding of what can be done.
    Though, they may be a little lackluster due to the low variety of items in the default helix/hl2rp schema.
]]

ix.Scavenging.InformationTables["Trash Pile"] = {
    ["Display Name"] = "Trash Pile",
    ["Display Description"] = "A pile of rubbish and garbage.",
    ["StartingModel"] = "models/props_junk/garbage128_composite001a.mdl",
    ["Inventory Width"] = 4,
    ["Inventory Height"] = 2,
    ["Usage Message"] = function( client, character, entity, ShouldScavenge )
        if( ShouldScavenge ) then
            return "Scavenging...";
        end
        return "Checking...";
    end,
    ["Amount of Spawned Items"] = function( client, character, entity )
        return 2;
    end,
    ["Amount of Spawned Credits"] = function( client, character, entity )
        return 0;
    end,
    ["Possible Items"] = function( client, character, entity )
        local Items = { 
            [1] = {
                ["ItemID"] = "water",
                ["Data"] = {},
                ["Chance"] = 2
            },
            [2] = {
                ["ItemID"] = "request_device",
                ["Data"] = {},
                ["Chance"] = 2
            }
        };
        return Items;
    end
};

ix.Scavenging.InformationTables["Broken Vending Machine"] = {
    ["Display Name"] = "Broken Vending Machine",
    ["Display Description"] = "A machine that once distributed cans of water. It doesn't seem to vend anymore.",
    ["StartingModel"] = "models/props_interiors/vendingmachinesoda01a.mdl",
    ["Inventory Width"] = 4,
    ["Inventory Height"] = 2,
    ["Usage Message"] = function( client, character, entity, ShouldScavenge )
        if( ShouldScavenge ) then
            return "Scavenging...";
        end
        return "Checking...";
    end,
    ["Amount of Spawned Items"] = function( client, character, entity )
        return 1;
    end,
    ["Amount of Spawned Credits"] = function( client, character, entity )
        return math.random( 5, 8 );
    end,
    ["Possible Items"] = function( client, character, entity )
        local Items = { 
            [1] = {
                ["ItemID"] = "water",
                ["Data"] = {},
                ["Chance"] = 16
            },
            [2] = {
                ["ItemID"] = "water_sparkling",
                ["Data"] = {},
                ["Chance"] = 3
            },
            [3] = {
                ["ItemID"] = "water_special",
                ["Data"] = {},
                ["Chance"] = 1
            }
        };
        return Items;
    end
};

ix.Scavenging.InformationTables["Abandoned Crate"] = {
    ["Display Name"] = "Abandoned Crate",
    ["Display Description"] = "A mysterious crate. It's content is entirely unknown until seen with one's eyes.",
    ["StartingModel"] = "models/props_junk/wood_crate001a.mdl",
    ["Inventory Width"] = 4,
    ["Inventory Height"] = 2,
    ["Usage Message"] = function( client, character, entity, ShouldScavenge )
        if( ShouldScavenge ) then
            return "Scavenging...";
        end
        return "Checking...";
    end,
    ["Amount of Spawned Items"] = function( client, character, entity )
        return 1;
    end,
    ["Amount of Spawned Credits"] = function( client, character, entity )
        return 0;
    end,
    ["Possible Items"] = function( client, character, entity )
        local Items = { 
            [1] = {
                ["ItemID"] = "bandage",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [2] = {
                ["ItemID"] = "chinese_takeout",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [3] = {
                ["ItemID"] = "combinelock",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [4] = {
                ["ItemID"] = "handheld_radio",
                ["Data"] = {
                    ["enabled"] = false
                },
                ["Chance"] = 1
            },
            [5] = {
                ["ItemID"] = "health_kit",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [6] = {
                ["ItemID"] = "health_vial",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [7] = {
                ["ItemID"] = "melon",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [8] = {
                ["ItemID"] = "metropolice_supplements",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [9] = {
                ["ItemID"] = "milk_carton",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [10] = {
                ["ItemID"] = "ration",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [11] = {
                ["ItemID"] = "request_device",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [12] = {
                ["ItemID"] = "supplements",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [13] = {
                ["ItemID"] = "water",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [14] = {
                ["ItemID"] = "water_sparkling",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [15] = {
                ["ItemID"] = "water_special",
                ["Data"] = {},
                ["Chance"] = 1
            },
            [16] = {
                ["ItemID"] = "zip_tie",
                ["Data"] = {},
                ["Chance"] = 1
            },
        };
        return Items;
    end
};