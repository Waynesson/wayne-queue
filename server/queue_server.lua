if not IsDuplicityVersion() then
    print("^1ERROR: Attempted to load server file on client^7")
    return
end

local Queue = {}
local QueueList = {}
local PlayerList = {}
local ConnectingPlayers = {}
local DISCORD_WEBHOOK = "DISCORD_WEBHOOK_HERE"

-- Role name mapping
function GetRoleName(roleId)
    local roleNames = {
        ["1234567890"] = "Founder",
        ["1234567890"] = "Community Manager",
        ["1234567890"] = "Staff",
        ["1234567890"] = "Diamond",
        ["1234567890"] = "Emerald",
        ["1234567890"] = "Platinum",
        ["1234567890"] = "Gold",
        ["1234567890"] = "Silver",
        ["1234567890"] = "Booster",
        ["1234567890"] = "Regular"
    }
    return roleNames[roleId] or "Unknown Role"
end

function FormatDiscordId(discordId)
    return "<@" .. discordId .. ">"
end

function SendDiscordLog(message, color)
    local embed = {
        {
            ["color"] = color or 3447003,
            ["title"] = "Queue System Log",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Server Queue Logs • " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({
        username = "Queue System",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

function Queue.GetDiscordId(source)
    local identifiers = GetPlayerIdentifiers(source)
    local discordId, steam, license, fivem = nil, nil, nil, nil
    
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, "discord:") then
            discordId = string.gsub(identifier, "discord:", "")
        elseif string.find(identifier, "steam:") then
            steam = identifier
        elseif string.find(identifier, "license:") then
            license = identifier
        elseif string.find(identifier, "fivem:") then
            fivem = identifier
        end
    end
    
    if discordId then
        print("^3[Queue Debug] Checking player: " .. GetPlayerName(source) .. "^7")
        print("^3[Queue Debug] Discord ID: " .. FormatDiscordId(discordId) .. "^7")
        
        -- Use Badger's API to get roles
        local roles = exports.Badger_Discord_API:GetDiscordRoles(source)
        local hasValidRole = false
        local validRoleName = nil
        
        if roles then
            print("^3[Queue Debug] Player roles:^7")
            for _, roleId in pairs(roles) do
                print("^3Role: " .. roleId .. " (" .. GetRoleName(roleId) .. ")^7")
                if Config.PriorityRoles[roleId] then
                    hasValidRole = true
                    validRoleName = GetRoleName(roleId)
                    print("^2[Queue Debug] Found valid role: " .. validRoleName .. "^7")
                    break
                end
            end
        end
        
        if hasValidRole then
            return discordId, nil, {steam = steam, license = license, fivem = fivem, discord = discordId}
        else
            print("^1[Queue Debug] No valid roles found^7")
            return nil, "You must have the Verified Role to join the server!", {steam = steam, license = license, fivem = fivem, discord = discordId}
        end
    else
        print("^1[Queue Debug] No Discord ID found^7")
        return nil, "You must link your Discord account to join the server!", {steam = steam, license = license, fivem = fivem, discord = "Not Linked"}
    end
end

function Queue.GetPriority(source)
    local roles = exports.Badger_Discord_API:GetDiscordRoles(source)
    if not roles then return 99 end
    
    local highestPriority = 99
    local priorityRoleName = "None"
    
    for _, roleId in pairs(roles) do
        if Config.PriorityRoles[roleId] and Config.PriorityRoles[roleId] < highestPriority then
            highestPriority = Config.PriorityRoles[roleId]
            priorityRoleName = GetRoleName(roleId)
            print(("^2[Queue Debug] Found priority role %s (%s) with level %d^7"):format(roleId, priorityRoleName, highestPriority))
        end
    end
    
    return highestPriority, priorityRoleName
end

function Queue.AddToQueue(source, deferrals)
    local discordId, errorMessage, identifiers = Queue.GetDiscordId(source)
    local playerName = GetPlayerName(source)
    
    local logMessage = string.format("Player Connecting:\nName: %s\nIdentifiers:\nDiscord: %s\nSteam: %s\nLicense: %s\nFiveM: %s",
        playerName,
        identifiers.discord and FormatDiscordId(identifiers.discord) or "Not Linked",
        identifiers.steam or "Not Linked",
        identifiers.license or "Not Linked",
        identifiers.fivem or "Not Linked"
    )
    
    if errorMessage then
        SendDiscordLog(logMessage .. "\nStatus: Rejected - " .. errorMessage, 15158332)
        deferrals.done(errorMessage)
        return
    end

    local priority, priorityRole = Queue.GetPriority(source)
    local player = {
        source = source,
        priority = priority,
        priorityRole = priorityRole,
        timestamp = os.time(),
        name = playerName,
        discordId = discordId,
        deferrals = deferrals,
        identifiers = identifiers,
        timeout = os.time() + Config.ConnectionTimeout
    }
    
    table.insert(QueueList, player)
    Queue.SortQueue()
    
    SendDiscordLog(logMessage .. string.format("\nStatus: Added to Queue\nPriority Level: %d (%s)", priority, priorityRole), 3066993)
    Queue.UpdateAllClients()
end

function Queue.SortQueue()
    table.sort(QueueList, function(a, b)
        if a.priority == b.priority then
            return a.timestamp < b.timestamp
        end
        return a.priority < b.priority
    end)
end

function Queue.ProcessQueue()
    local currentPlayers = GetNumPlayerIndices()
    local currentTime = os.time()
    
    for i = #QueueList, 1, -1 do
        local player = QueueList[i]
        
        -- Check for timeout
        if currentTime > player.timeout then
            SendDiscordLog(string.format("Player Timed Out:\nName: %s\nDiscord: %s\nPriority: %d (%s)", 
                player.name,
                player.discordId and FormatDiscordId(player.discordId) or "Not Linked",
                player.priority,
                player.priorityRole
            ), 15158332)
            if player.deferrals then
                player.deferrals.done(Config.Messages.timeout)
            end
            table.remove(QueueList, i)
            goto continue
        end
        
        if currentPlayers < Config.MaxPlayers then
            if player and player.deferrals then
                SendDiscordLog(string.format("Player Connected:\nName: %s\nDiscord: %s\nPriority: %d (%s)\nQueue Position: %d/%d",
                    player.name,
                    player.discordId and FormatDiscordId(player.discordId) or "Not Linked",
                    player.priority,
                    player.priorityRole,
                    i,
                    #QueueList
                ), 3066993)
                
                player.deferrals.done()
                table.remove(QueueList, i)
                currentPlayers = currentPlayers + 1
            end
        else
            if player and player.deferrals then
                local message = player.priority < 99 
                    and string.format(Config.Messages.priority, i, #QueueList)
                    or string.format(Config.Messages.position, i, #QueueList)
                player.deferrals.update(message)
            end
        end
        
        ::continue::
    end
    
    Queue.UpdateAllClients()
end

function Queue.UpdateAllClients()
    for i, player in ipairs(QueueList) do
        if player.deferrals then
            local message = player.priority < 99 
                and string.format(Config.Messages.priority, i, #QueueList)
                or string.format(Config.Messages.position, i, #QueueList)
            player.deferrals.update(message)
        end
    end
end

function Queue.IsPlayerBanned(source)
    return false
end

function Queue.IsPlayerWhitelisted(source)
    return true
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    
    local source = source
    deferrals.update(Config.Messages.connecting)
    
    Wait(500)
    
    Queue.AddToQueue(source, deferrals)
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    
    for i = #QueueList, 1, -1 do
        if QueueList[i].source == source then
            SendDiscordLog(string.format("Player Disconnected from Queue:\nName: %s\nDiscord: %s\nPriority: %d (%s)\nReason: %s",
                QueueList[i].name,
                QueueList[i].discordId and FormatDiscordId(QueueList[i].discordId) or "Not Linked",
                QueueList[i].priority,
                QueueList[i].priorityRole,
                reason
            ), 15105570)
            
            table.remove(QueueList, i)
            break
        end
    end
    
    Queue.UpdateAllClients()
end)

CreateThread(function()
    while true do
        Queue.ProcessQueue()
        Wait(Config.RefreshTime)
    end
end)

print("^2[Queue] System initialized successfully^7")