fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'lnd'
description 'Support: https://discord.gg/dEv6tm2epA'
version '1.0.7'

shared_script {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_script 'client/main.lua'

server_script 'server/main.lua'