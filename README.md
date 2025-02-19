# Wayne Queue System
An advanced queue system for FiveM servers with Discord integration and priority queue support.

## Features
- 🎮 Seamless FiveM server queue management
- 🔐 Discord role-based priority system
- 📊 Real-time queue position updates
- 🎨 Modern and responsive UI
- 📝 Detailed Discord logging
- ⚡ Performance optimized
- 🛡️ Secure connection handling
- ⏱️ Configurable timeout settings

## Requirements
- FiveM Server
- [Badger_Discord_API](https://github.com/JaredScar/Badger_Discord_API)
- Discord Bot
- Discord Server (Guild)

## Installation
1. Download the latest release
2. Extract `wayne-queue` to your server's resources folder
3. Configure your Discord credentials in `credentials.lua`:
4. Configure priority roles in `server/queue_config.lua`
5. Add `ensure wayne-queue` to your server.cfg

## Configuration
### Priority Roles
Edit `server/queue_config.lua` to set up your priority roles:
