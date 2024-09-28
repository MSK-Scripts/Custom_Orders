fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_vehicleShowRoom'
description 'Show Room for vehicles'
version '1.0'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_script 'client.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'es_extended',
    'oxmysql'
}