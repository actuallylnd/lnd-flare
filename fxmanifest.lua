fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'lnd'

shared_script {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_script 'client/main.lua'

server_script 'server/main.lua'