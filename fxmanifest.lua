fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'barScripts'
description 'Vehicle Liveries UI'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js'
}

ui_page 'html/index.html'

dependencies {
    'ox_lib'
}
