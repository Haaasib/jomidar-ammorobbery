Config = {}

Config.CheckForUpdates = true

Config.CoreName = 'qb-core' --core name
Config.StartPedLoc = vector4(884.68, -953.22, 39.21, 359.05)

Config.PedModel = "a_m_m_og_boss_01"

Config.StartPedAnimation = "WORLD_HUMAN_AA_SMOKE"

Config.PoliceJobtype = "leo" --policejob type (not job name)

Config.Cooldown = 30 --in minutes

Config.CopAmount = 0

Config.requiredItem = "weapon_knife"

Config['containers'] = {
    {
        pos = vector3(1091.08, -3188.91, 4.9), 
        heading = 0.0, 
        lock = {pos = vector3(1091.04, -3190.76, 6), taken = false},
        box = vector4(1091.0, -3187.94, 5.1, 355.21),
        containerModel = 'tr_prop_tr_container_01a',
        target = vector3(1091.0, -3191.08, 5.9)
        
    },
    {
        pos = vector3(1096.84, -3188.75, 4.9), 
        heading = 0.0, 
        lock = {pos = vector3(1096.87, -3190.61, 6), taken = false},
        box = vector4(1096.77, -3187.8, 5.1, 355.88),
        containerModel = 'tr_prop_tr_container_01h',
        target = vector3(1096.87, -3190.82, 5.9)
    },
    {
        pos = vector3(1101.13, -3188.95, 4.9), 
        heading = 0.0, 
        lock = {pos = vector3(1101.17, -3190.81, 6), taken = false},
        box = vector4(1101.2, -3188.0, 5.1, 355.36),
        containerModel = 'tr_prop_tr_container_01i',
        target = vector3(1101.17, -3191.02, 5.9)
    },
    {
        pos = vector3(1101.26, -3198.25, 4.9), 
        heading = 180.0, 
        lock = {pos = vector3(1101.27, -3196.39, 6), taken = false},
        box = vector4(1101.2, -3199.24, 5.1, 180.77),
        containerModel = 'tr_prop_tr_container_01c',
        target = vector3(1101.3, -3196.09, 5.9)
    },
    {
        pos = vector3(1096.83, -3197.88, 4.9), 
        heading = 180.0, 
        lock = {pos = vector3(1096.83, -3196.03, 6), taken = false},
        box = vector4(1096.81, -3198.84, 5.1, 180.77),
        containerModel = 'tr_prop_tr_container_01f',
        target = vector3(1096.77, -3195.75, 5.9)
    },
    {
        pos = vector3(1091.1, -3198.18, 4.9), 
        heading = 180.0, 
        lock = {pos = vector3(1091.08, -3196.33, 6), taken = false},
        box = vector4(1091.01, -3199.12, 5.1, 180.77),
        containerModel = 'tr_prop_tr_container_01g',
        target = vector3(1091.03, -3195.99, 5.9)
    },
}

--Items that drop in crate, if you want to randomize it just add more sub-lists
Config.UseStash = true -- make it false if you re using latest qb inventory or any other inventory or you are not getting items in your stash

Config.WithoutStashItem = {  --- if usestash is false then config item here. and its rnd from here player will get 1 item
    { name = "weapon_smg", amount = 1 },
    { name = "heavyarmor", amount = 1 },
}


--Items that drop in crate, if you want to randomize it just add more sub-lists

Config.Items = {
    {
        {
            info = {},
            unique = true,
            image = "weapon_smg.png",
            amount = 3,
            name = "weapon_smg",
            slot = 3,
            useable = true,
            weight = 100,
            type = "weapon",
            label = "SMG"
        },
        {
            info = {},
            unique = true,
            image = "heavyarmor.png",
            amount = 1,
            name = "heavyarmor",
            slot = 4,
            useable = false,
            weight = 1000,
            type = "item",
            label = "Heavy Armor"
        }
    },
    {
        {
            info = {},
            unique = true,
            image = "weapon_smg.png",
            amount = 1,
            name = "weapon_smg",
            slot = 3,
            useable = true,
            weight = 100,
            type = "weapon",
            label = "SMG"
        },
        {
            info = {},
            unique = true,
            image = "heavyarmor.png",
            amount = 1,
            name = "heavyarmor",
            slot = 4,
            useable = false,
            weight = 1000,
            type = "item",
            label = "Heavy Armor"
        }
    },
}


Config.GuardPeds = { -- guard ped list (you can add new)
    { coords = vector3(1101.74, -3200.51, 5.9), heading = 270.87, model = 's_m_y_blackops_01'},
    { coords = vector3(1107.77, -3204.41, 15.97), heading = 177.93, model = 's_m_y_blackops_01'},
    { coords = vector3(1105.27, -3190.1, 15.97), heading = 354.93, model = 's_m_y_blackops_01'},
    { coords = vector3(1111.72, -3195.42, 5.9), heading = 177.88, model = 's_m_y_blackops_01'},
}

-------------------------------dispatch--------------------------

AlertCops = function()

    exports['ps-dispatch']:Shooting()
    
end



--Dont change. Main and required things.
ContainerAnimation = {
    ['objects'] = {
        'tr_prop_tr_grinder_01a',
        'ch_p_m_bag_var02_arm_s'
    },
    ['animations'] = {
        {'action', 'action_container', 'action_lock', 'action_angle_grinder', 'action_bag'}
    },
    ['scenes'] = {},
    ['sceneObjects'] = {}
}

