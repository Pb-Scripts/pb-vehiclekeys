fx_version 'cerulean'
game 'gta5'
author "Pb"


lua54 'yes'

client_script 'client.lua'

server_scripts {
    'server.lua'
}

shared_scripts {
    '@pb-utils/init.lua',
    'config.lua'
}

dependencies {
    'pb-utils'
}
