module.exports = class CozySocketListener
    # Add '../lib/client.js' to vendor files.
    # when dependency in clients' package.json
    brunchPlugin: yes
    include: ["../lib/client.js"]

    @serverInitializer = require './server'