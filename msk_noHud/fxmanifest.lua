fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15'
name 'msk_noHud'
description 'Status Notification'
version '1.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}

dependencies {
    'es_extended'
}