fx_version 'adamant'
game 'gta5'
author 'Kiwi & REWORK BY SYRONE'
description 'kAdmin'

fx_version 'cerulean'

games { 'gta5' }

lua54 'yes'


shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'config/*.lua',
    'client/*.lua'
    
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'config/*.lua',
    'server/*.lua'
}