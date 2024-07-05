fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_vehicleregistration'
description 'Registration Office for Vehicle'
version '1.0'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@msk_core/import.lua',
	'@ox_lib/init.lua',
	'translation.lua',
	'config.lua'
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}