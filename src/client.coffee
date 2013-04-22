Task = require('models/task').Task

class SocketListener

    models: {}
    events: []

    onRemoteCreation: (model) ->
    onRemoteUpdate: (model, collection) ->
    onRemoteDelete: (model, collection) ->
    shouldBeAdded: (model, collection) -> true

    constructor: () ->
        try
            @connect()
        catch err
            console.log "Error while connecting to socket.io"
            console.log err.stack

        @collections = []
        @tmpcollection = new Backbone.Collection()
        @watch @tmpcollection
        @stack = []
        @ignore = []
        @paused = 0

    connect: ->
        url = window.location.origin
        pathToSocketIO = "#{window.location.pathname.substring(1)}socket.io"
        socket = io.connect url,
                resource: pathToSocketIO

        for event in @events
            socket.on event, @callbackFactory(event)

    watch: (collection) ->
        @collections.push collection
        collection.on 'request', @pause
        collection.on 'sync', @resume
        collection.on 'destroy', @resume
        collection.on 'error', @resume

    watchOne: (model) ->
        @collections[0].add model

    pause: (model, xhr, options) =>
        if options.ignoreMySocketNotification

            operation = if model.isNew() then 'create' else 'update'

            doctype = null
            for key, Model of @models
                doctype = key if model instanceof Model

            return unless doctype?

            @ignore.push
                doctype:   doctype,
                operation: operation,
                model:     model

            @paused = @paused + 1

    resume: (model, resp, options) =>
        if options.ignoreMySocketNotification
            @paused = @paused - 1
            if @paused <= 0
                @processStack()
                @paused = 0

    cleanStack: ->
        ignoreIndex = 0
        while ignoreIndex < @ignore.length
            removed = false
            stackIndex = 0
            ignoreEvent = @ignore[ignoreIndex]

            while stackIndex < @stack.length
                stackEvent = @stack[stackIndex]
                if stackEvent.operation is ignoreEvent.operation and \
                          stackEvent.id is ignoreEvent.model.id
                    @stack.splice stackIndex, 1
                    removed = true
                    break;
                else
                    stackIndex++

            if removed
                @ignore.splice ignoreIndex, 1
            else
                ignoreIndex++

    callbackFactory: (event) => (id) =>
        [doctype, operation] = event.split '.'
        fullevent = id: id, doctype: doctype, operation: operation

        @stack.push fullevent
        @processStack() if @paused == 0

    processStack: =>
        @cleanStack()

        while @stack.length > 0
            @process @stack.shift()

    process: (event) ->
        {doctype, operation, id} = event
        switch operation
            when 'create'
                model = new @models[doctype](id: id)
                model.fetch
                    success: @onRemoteCreation

            when 'update'
                @collections.forEach (collection) =>
                    return unless model = collection.get id
                    model.fetch
                        success: (fetched) =>
                            if fetched.changedAttributes()
                                @onRemoteUpdate fetched, collection

            when 'delete'
                @collections.forEach (collection) ->
                    return unless model = collection.get id
                    @onRemoteDelete task, collection



module.exports = SocketListener