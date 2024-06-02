local activeBlips = {}

-- Notify specific jobs
RegisterServerEvent('notstomped_emergencyCall:notifyJobs')
AddEventHandler('notstomped_emergencyCall:notifyJobs', function(jobRoles, coords, command, blipColor, message)
    local jobs = {'hollowimport', 'ambulance', 'police', 'metro', 'coiu'}
    local source = source
    for _, job in ipairs(jobRoles) do
        TriggerClientEvent('notstomped_emergencyCall:createBlip', -1, coords, blipColor, jobRoles, source, message)
    end
end)
-- call accepted
RegisterServerEvent('notstomped_emergencyCall:callAccepted')
AddEventHandler('notstomped_emergencyCall:callAccepted', function(callerId, responderJob)
    TriggerClientEvent('notstomped_emergencyCall:notifyCaller', callerId, Config.Notifications.CallAccepted[responderJob])
end)
-- call declined
RegisterServerEvent('notstomped_emergencyCall:callRejected')
AddEventHandler('notstomped_emergencyCall:callRejected', function(callerId)
    TriggerClientEvent('notstomped_emergencyCall:notifyCaller', callerId, Config.Notifications.CallRejected)
end)
-- call passed to other departments
RegisterServerEvent('notstomped_emergencyCall:callPassed')
AddEventHandler('notstomped_emergencyCall:callPassed', function(callerId, responderJob)
    TriggerClientEvent('notstomped_emergencyCall:notifyCaller', callerId, Config.Notifications.CallPassed)
end)

-- end last call
RegisterServerEvent('notstomped_emergencyCall:endLatestCall')
AddEventHandler('notstomped_emergencyCall:endLatestCall', function()
    local source = source
    TriggerClientEvent('notstomped_emergencyCall:endLatestCallNotification', -1)
end)


-- end all calls
RegisterServerEvent('notstomped_emergencyCall:endAllCalls')
AddEventHandler('notstomped_emergencyCall:endAllCalls', function()
    local source = source
    TriggerClientEvent('notstomped_emergencyCall:endAllCallsNotification', -1)
end)

