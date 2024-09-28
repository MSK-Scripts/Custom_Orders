fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_vehicleseller'
description 'Sell your vehicles'
version '1.1'

lua54 'yes'

shared_script {
    '@es_extended/imports.lua',
	'@msk_core/import.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'translation.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib',
    'msk_core'
}