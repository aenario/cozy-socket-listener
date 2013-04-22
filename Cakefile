{exec} = require 'child_process'

task 'tests', 'run tests', ->
    commanc  = "mocha tests/client.coffee tests/server.coffee"
    command += "--compilers coffee:coffee-script --colors"
    exec command


task 'build', 'build src into lib', ->
    exec "coffee --output lib --compile src"