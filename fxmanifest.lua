fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Az-Quests'
author 'Azure-Framework'
description 'Config-driven quests with a themed NUI (/quests) and location-based completion.'
version '1.0.0'

shared_scripts {
  'config.lua'
}

client_scripts {
  'client.lua'
}

server_scripts {
  'server.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/app.js'
}
