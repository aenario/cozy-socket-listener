{exec} = require 'child_process'

task 'tests', 'run tests', ->
    commanc  = "mocha tests/client.coffee tests/server.coffee"
    command += "--compilers coffee:coffee-script --colors"
    exec command

task 'build', 'build src into lib', ->
    exec "coffee --output lib --compile src"

task 'cpclient', 'copy client in brunch vendors', ->
    command  = "cp lib/client.js "
    command += "../../client/vendor/scripts/socketlistener-0.0.2.js"
    exec command