function Dispatch(playerPed, coords)
    print('Player: '..playerPed ..' Coords: '..coords)
end

Config = {

    Debug = true,

    TaskDuration = 25 * 60 * 1000,
    WarningTime = 25 * 60 * 1000, 

    Dispatch = true,

    RequiredPolice = 1,

    OrderCooldown = 180000, -- Give time in milliseconds

    PedModel = "a_m_m_skidrow_01",

    talkped = vec4(-1517.0228, 1502.7448, 111.6212 - 1.0, 78.2675),
    
    AnimationPed = "WORLD_HUMAN_DRINKING",

    ZonePed =  {
        coords = vec3(-1518.0, 1503.0, 112.0),
        radius = 20,
    },

    chestprop = `ba_prop_battle_chest_closed`,

    ZoneRadius = 125.0,

    CleanTime = 5000, -- After 5 secounds flare effect, blip and chest will be deleted 

    RequiredItemEnabled = false,

    RequiredItem = 'phone',

    RequiredItemQuanity = 1,

    SkillCheckSettings = {
        Difficulties = { 'easy', 'easy', 'easy', 'medium', 'medium', {areaSize = 60, speedMultiplier = 1}, 'easy' },
        Keys = { 'w', 's', 'a', 'd', 'e' }
    },

    -- You can add more zones 
    Zones = {
        {
            ZoneName = "Zone1",
            FlareCoords = vec4(2027.8724, 3867.4446, 32.0412, 125.0),
            BlipCoord = vector3(2027.8724, 3867.4446, 32.0412),
            chests = {
                vec3(2030.4379, 3850.2961, 33.2791),
                vec3(2048.6338, 3860.1238, 32.9191),
                vec3(2043.4739, 3869.6765, 32.9191),
                vec3(2027.2856, 3860.9333, 33.2394),
                vec3(2017.8037, 3861.7388, 33.3780),
                vec3(2032.5775, 3880.7380, 32.9945),
            }
        },
        --[[
        {
            ZoneName = "Zone2",
            FlareCoords = vec4(-1391.8510, 4431.8545, 31.0721, 125.0),
            BlipCoord = vector3(-1391.8510, 4431.8545, 31.0721),
            chests = {
                vec3(-1408.0536, 4484.6885, 23.5398),
                vec3(-1399.6211, 4482.0737, 23.9158),
                vec3(-1388.1498, 4475.6929, 24.9559),
                vec3(-1369.3124, 4471.1899, 24.5372),
                vec3(-1356.9169, 4471.6626, 23.6342),
                vec3(-1346.6313, 4473.0483, 23.1873),
                vec3(-1344.3336, 4466.0337, 23.2150),
                vec3(-1331.1432, 4475.3203, 23.1285)
            }
        },
        {
            ZoneName = "Zone3",
            FlareCoords = vec4(2102.3643, 4818.9321, 41.3928, 230.7917),
            BlipCoord = vector3(2102.3643, 4818.9321, 41.3928),
            chests = {
                vec3(2146.0178, 4781.8418, 40.9932),
                vec3(2120.6528, 4782.8623, 40.9703),
                vec3(2137.4961, 4831.9800, 41.6411),
            }
        },
        {
            ZoneName = "Zone4",
            FlareCoords = vec4(2057.8054, 4778.2754, 41.0796, 125.4426),
            BlipCoord = vector3(2057.8054, 4778.2754, 41.0796),
            chests = {
                vec3(2058.0085, 4756.4810, 40.7344),
                vec3(2043.2356, 4789.5171, 41.5346),
                vec3(2032.3922, 4781.9761, 41.5933),
                vec3(2062.0071, 4772.4644, 41.3323),
            }
        },
        {      
            ZoneName = "Zone5",
            FlareCoords = vec4(1250.6259, 6577.0952, 2.5049, 91.5874),
            BlipCoord = vector3(1250.6259, 6577.0952, 2.5049),
            chests = {
                vec3(1241.4928, 6560.2515, 2.8267),
                vec3(1263.8236, 6589.4492, 2.1047),
                vec3(1262.7639, 6598.1860, 2.0759),
                vec3(1242.5806, 6587.4155, 2.1408),
                vec3(1235.9857, 6553.2397, 4.3221),
                vec3(1249.1864, 6545.9419, 5.0128),
            }
        },
        {
            ZoneName = "Zone6",
            FlareCoords = vec4(-2179.1660, 4524.6807, 34.5992, 9.3162),
            BlipCoord = vector3(-2179.1660, 4524.6807, 34.5992),
            chests = {
                vec3(-2179.1660, 4524.6807, 34.5992),
                vec3(-2193.1418, 4508.4043, 34.3825),
                vec3(-2165.1416, 4511.8013, 35.2114),
                vec3(-2180.4744, 4530.9546, 33.0771),
                vec3(-2196.9565, 4503.7505, 34.3467),
                vec3(-2198.1060, 4530.2520, 15.6162),
            }
        },
        {
            ZoneName = "Zone7",
            FlareCoords = vec4(-2251.5349, 2458.1187, 5.4699, 85.9420),
            BlipCoord = vector3(-2251.5349, 2458.1187, 5.4699),
            chests = {
                vec3(-2245.1753, 2454.6873, 6.5615),
                vec3(-2232.7778, 2452.4016, 8.4561),
                vec3(-2212.3501, 2485.8713, 7.2647),
                vec3(-2232.1104, 2497.3357, 2.6570),
                vec3(-2252.0198, 2485.4573, 1.4558),
            }
        },
        {
            ZoneName = "Zone8",
            FlareCoords = vec4(675.4687, -2035.0293, 9.1088, 50.7134),
            BlipCoord = vector3(675.4687, -2035.0293, 9.1088),
            chests = {
                vec3(665.3505, -2032.1096, 8.5854),
                vec3(662.2340, -1995.9711, 8.1551),
                vec3(680.3124, -2041.5736, 9.4259),
                vec3(668.2697, -2082.4404, 8.4856),
            }
        },
        --]]
    },    

    -- TRANSLATION --

    translation = {
        no_required_item = 'You don\'t have required item',
        stolen = 'Someone has stolen your chest!',
        start = 'Listen, there is a hidden box and I have not been able to find it, maybe you can find it if it turns out that the contents belong to you',
        started = 'Find this box!',
        cooldownnotif = 'Get away from me',
        finish = 'You opened the chest and got some items.',
        starttimer = 'You have 30 minutes to do it!',
        endreminder = '5 minutes left until the flare ends!',
        timeend = 'Time has passed maybe next time you will succeed!',
        blipname = "Search Area", 
        open = 'Open',
        talk = 'Talk',
        descStart = 'When you click ped it gives you an area to search the crate as you find the crate then open it and take items from it',
        title = 'Start Flare',
        menuTitle = 'Henk',
        no_required_police = 'Lack of enough officers'
    }
}
