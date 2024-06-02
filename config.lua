Config = {}

-- Notification messages
Config.Notifications = {
    CallSent = "Notruf abgesendet.",
    CallAccepted = {
        police = "Police is on their way.",
        metro = "Police is on their way.",
        ambulance = "EMS is on their way.",
        hollowimport = "HI is on their way",
        coiu = "Units are on their way."
    },
    CallRejected = "All unites are tied elsewhere.",
    CallPassed = "Call tranfered to other departments.",
    CallEnded = "Call ended.",
    AcceptDeclinePromt = "WIP", -- wip
    AcceptPrompt = "New Call: {message}",
    CooldownActive = "The line is busy for {remaining} seconds."
}

-- Blip settings
Config.Blips = {
    Type = 1,
    Size = 0.85,
    Colors = {
        ['911'] = 3,
        ['912'] = 1,
        ['909'] = 2,
        ['501835720'] = 0,
        ['end'] = 4
    },
    Name = "Emergency"
}

-- Command cooldowns (in seconds)
Config.Cooldown = 10 -- 10 seconds

-- Blip removal timing
Config.BlipRemoveTime = 600 -- 10 minutes in seconds

-- Blip removal timing with the /end and /endall commands
Config.EndBlipRemoveTime = 5 -- 5 seconds
