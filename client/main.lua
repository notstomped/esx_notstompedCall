local callCooldown = {}
local activeBlips = {}


-- function to create blip
local function createBlip(coords, color, name)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, Config.Blips.Type)
    SetBlipScale(blip, Config.Blips.Size)
    SetBlipColour(blip, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)

    -- blip timer (config.lua)
    Citizen.SetTimeout(Config.BlipRemoveTime * 1000, function()
        RemoveBlip(blip)
    end)

    return blip
end

-- check if job exists in table
local function jobExists(job, jobTable)
    for _, v in ipairs(jobTable) do
        if v == job then
            return true
        end
    end
    return false
end

-- ensure ESX is loaded (outdated)
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- handle call commands
local function handleCall(jobRoles, command, blipColor, message)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local job = ESX.GetPlayerData().job.name

    -- check cooldown
    if callCooldown[command] and GetGameTimer() - callCooldown[command] < Config.Cooldown * 1000 then
        local remaining = math.ceil((Config.Cooldown * 1000 - (GetGameTimer() - callCooldown[command])) / 1000)
        ESX.ShowNotification(Config.Notifications.CooldownActive:gsub("{remaining}", remaining))
        return
    end

    ESX.ShowNotification(Config.Notifications.CallSent)

    -- Add blip for specified jobs
    TriggerServerEvent('notstomped_emergencyCall:notifyJobs', jobRoles, playerCoords, command, blipColor, message)
    callCooldown[command] = GetGameTimer()
end


-- command registry
RegisterCommand('911', function(_, args)
    local message = table.concat(args, " ")
    handleCall({'police', 'metro'}, '911', Config.Blips.Colors['911'], message)
end, false)

RegisterCommand('912', function(_, args)
    local message = table.concat(args, " ")
    handleCall({'ambulance'}, '912', Config.Blips.Colors['912'], message)
end, false)

RegisterCommand('909', function(_, args)
    local message = table.concat(args, " ")
    handleCall({'dhs'}, '909', Config.Blips.Colors['909'], message)
end, false)

RegisterCommand('501835720', function(_, args)
    local message = table.concat(args, " ")
    handleCall({'coiu'}, '501835720', Config.Blips.Colors['501835720'], message)
end, false)


-- blip call stuff
RegisterNetEvent('notstomped_emergencyCall:createBlip')
AddEventHandler('notstomped_emergencyCall:createBlip', function(coords, blipColor, acceptRoles, callerId, message)
    local jobs = {'hollowimport', 'ambulance', 'police', 'metro', 'coiu'}
    local job = ESX.GetPlayerData().job.name
    if jobExists(job, jobs) then
        local blip = createBlip(coords, blipColor, Config.Blips.Name)
        table.insert(activeBlips, blip)
        if jobExists(job, acceptRoles) then
            ESX.ShowNotification(Config.Notifications.AcceptPrompt:gsub("{message}", message))
        end

        local accepted = false
        Citizen.CreateThread(function()
            local timer = GetGameTimer()
            while not accepted and GetGameTimer() - timer < 10000 do
                Citizen.Wait(0)
                if jobExists(job, acceptRoles) then
                    if IsControlJustReleased(0, 38) then -- E key
                        accepted = true
                        SetNewWaypoint(coords.x, coords.y)  -- Set the waypoint to the coordinates of the blip
                        TriggerServerEvent('notstomped_emergencyCall:callAccepted', callerId, job)
                    elseif IsControlJustReleased(0, 47) then -- G key
                        accepted = true
                        RemoveBlip(blip)
                        TriggerServerEvent('notstomped_emergencyCall:callRejected', callerId)
                    end
                end
            end

            if not accepted and jobExists(job, acceptRoles) then
                TriggerServerEvent('notstomped_emergencyCall:callPassed', callerId, job)
            end
        end)
    end
end)


-- /end command
RegisterCommand('end', function()
    local job = ESX.GetPlayerData().job.name
    if jobExists(job, {'police', 'ambulance', 'hollowimport', 'metro', 'coiu'}) then
        TriggerServerEvent('notstomped_emergencyCall:endLatestCall')
    end
end, false)

RegisterNetEvent('notstomped_emergencyCall:endLatestCallNotification')
AddEventHandler('notstomped_emergencyCall:endLatestCallNotification', function()
    ESX.ShowNotification(Config.Notifications.CallEnded)
    if #activeBlips > 0 then
        local latestBlip = table.remove(activeBlips)
        SetBlipColour(latestBlip, Config.Blips.Colors['end'])
        Citizen.SetTimeout(Config.EndBlipRemoveTime * 1000, function()
            RemoveBlip(latestBlip)
        end)
    end
end)

-- /endall command
RegisterCommand('endall', function()
    local job = ESX.GetPlayerData().job.name
    if jobExists(job, {'police', 'ambulance', 'hollowimport', 'metro', 'coiu'}) then
        TriggerServerEvent('notstomped_emergencyCall:endAllCalls')
    end
end, false)

RegisterNetEvent('notstomped_emergencyCall:endAllCallsNotification')
AddEventHandler('notstomped_emergencyCall:endAllCallsNotification', function()
    ESX.ShowNotification(Config.Notifications.CallEnded)
    for _, blip in ipairs(activeBlips) do
        SetBlipColour(blip, Config.Blips.Colors['end'])
        Citizen.SetTimeout(Config.EndBlipRemoveTime * 1000, function()
            RemoveBlip(blip)
        end)
    end
    activeBlips = {}
end)


RegisterNetEvent('notstomped_emergencyCall:notifyCaller')
AddEventHandler('notstomped_emergencyCall:notifyCaller', function(message)
    ESX.ShowNotification(message)
end)


-- print("notstompedCall loaded")
