fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_deathradar'
description 'Creates Blips if they are dead'
version '1.0'

shared_script {
    '@es_extended/imports.lua',
    'config.lua'
}

client_script 'client.lua'

server_script 'server.lua'

dependencies {
    'es_extended'
}