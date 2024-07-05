Config = {}

Config.Method = 'self' -- Set to 'fixed' or 'self'

Config.Size  = {x = 1.0, y = 1.0, z = 0.8}
Config.Color = {r = 255, g = 255, b = 255}
Config.Type  = 36

Config.Locations = {
    ['military_1'] = {
        coords = vec3(-2108.75, 2864.84, 32.81),
        heading = 0.0,
        distance = 50.0,
        jobs = {enable = true, jobs = {'police'}},
        model = 'nero2',
        colors = { -- https://pastebin.com/pwHci0xK
            enable = true, -- Set false to use random color
            primary = 0,
            secondary = 0
        },
        plate = 'show 1', -- Set false to use default plate
        rotate = {
            enable = true,
            speed = 0.1
        }
    },
    ['military_2'] = {
        coords = vec3(-2117.81, 2872.37, 32.81),
        heading = 0.0,
        distance = 50.0,
        jobs = {enable = true, jobs = {'police'}},
        model = 'zentorno',
        colors = { -- https://pastebin.com/pwHci0xK
            enable = false, -- Set false to use random color
            primary = 27,
            secondary = 0
        },
        plate = false, -- Set false to use default plate
        rotate = {
            enable = false,
            speed = 0.1
        }
    },
}