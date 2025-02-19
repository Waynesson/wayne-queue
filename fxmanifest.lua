fx_version 'cerulean'
game 'gta5'

author 'Waynesson'
description 'Advanced Queue System with Discord Integration'
version '1.0.0'

shared_scripts {
    'server/queue_config.lua'
}

server_scripts {
    'server/queue_server.lua'
}

client_scripts {
    'client/queue_client.lua'
}

ui_page 'html/queue.html'

files {
    'html/queue.html',
    'html/queue.css',
    'html/queue.js'
}