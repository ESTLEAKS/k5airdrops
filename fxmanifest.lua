fx_version 'cerulean'
game 'gta5'

author 'k5'
description 'k5 Advanced Airdrop System for ESX with okokNotify'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'server.lua'
}

files {
    'config.lua'
}

dependencies {
    'es_extended',
    'okokNotify'
}
