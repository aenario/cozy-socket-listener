module.exports = class SocketListener

    # Add '../lib/client.js' to vendor files.
    # when dependency in clients' package.json
    brunchPlugin: yes
    include: ["../lib/client.js"]

module.exports.serverInitializer = require './server'