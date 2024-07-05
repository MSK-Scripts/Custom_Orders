fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_vehicleclothing'
description 'Kleidung am Kofferraum eines Fahrzeugs wechseln'
version '1.0'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
	'client.lua'
}

ui_page 'html/index.html'

files {
	"html/**/*.*"
}

dependencies {
	'es_extended'
}