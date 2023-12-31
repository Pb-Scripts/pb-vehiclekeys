fx_version 'cerulean'
game 'gta5'
author "Pb"


lua54 'yes'
files {
    'locales/*.json'
}

client_script 'client.lua'

server_scripts {
    'server.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}