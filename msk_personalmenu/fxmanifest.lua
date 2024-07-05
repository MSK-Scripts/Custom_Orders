fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_personalmenu'
description 'Personalmenu'
version '1.0'

lua54 'yes'

shared_script {
    '@es_extended/imports.lua',
    '@msk_core/import.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    '@NativeUI/NativeUI.lua',
    'client.lua',
    'client_*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'server_*.lua'
}

ui_page 'html/index.html'

files {
	"html/**/*.*",
}

dependencies {
    'es_extended',
    'msk_core',
    'msk_banking',
    'msk_handcuffs'
}