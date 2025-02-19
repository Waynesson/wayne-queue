local isInQueue = false
local queuePosition = 0
local totalInQueue = 0
local isConnecting = false

local function ShowQueueUI(show)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "showQueue",
        display = show,
        position = queuePosition,
        total = totalInQueue,
        message = string.format(
            isConnecting and Config.Messages.connecting or Config.Messages.position,
            queuePosition,
            totalInQueue
        )
    })
end

RegisterNetEvent('queue:updatePosition')
AddEventHandler('queue:updatePosition', function(position, total)
    queuePosition = position
    totalInQueue = total
    isInQueue = position > 0
    ShowQueueUI(isInQueue)
end)

RegisterNetEvent('queue:startConnecting')
AddEventHandler('queue:startConnecting', function()
    isConnecting = true
    ShowQueueUI(true)
end)

Citizen.CreateThread(function()
    while true do
        if isInQueue or isConnecting then
            DisableAllControlActions(0)
            EnableControlAction(0, 200, true)
        end
        Citizen.Wait(0)
    end
end)