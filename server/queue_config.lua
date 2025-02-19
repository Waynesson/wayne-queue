Config = {
    -- Queue Configuration
    MaxPlayers = 8,
    RefreshTime = 1000, -- Queue refresh time in ms
    ConnectionTimeout = 30, -- Seconds before timing out a connection attempt
    
    -- Priority Levels (1 is highest)
    PriorityRoles = {
        ["1234567890"] = 1, -- Example: Founder
        ["1234567890"] = 2, -- Example: Community Manager
        ["1234567890"] = 3, -- Example: Staff Role
        ["1234567890"] = 4, -- Example: Diamond
        ["1234567890"] = 5, -- Example: Emerald
        ["1234567890"] = 6, -- Example: Platinum
        ["1234567890"] = 7, -- Example: Gold
        ["1234567890"] = 8, -- Example: Silver
        ["1234567890"] = 9, -- Example: Server Booster
        ["1234567890"] = 10 -- Example: Regular
    },
    
    -- Messages
    Messages = {
        connecting = "Connecting to server...",
        position = "You are in position %d of %d",
        priority = "Priority Queue: Position %d of %d",
        error = "Error connecting to server. Please try again.",
        timeout = "Connection timed out. Please try again.",
        welcome = "Welcome to the server!",
        disconnected = "You have been disconnected from the queue.",
        rejoining = "Rejoining queue...",
        banned = "You are banned from this server.",
        whitelist = "You are not whitelisted on this server."
    }
}