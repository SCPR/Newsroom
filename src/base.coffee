_u      = require 'underscore'
path    = require 'path'
express = require 'express'
io      = require 'socket.io'

User   = require('./user')
Room   = require('./room')
Record = require('./record')

class Base
    constructor: (port)->
        # Setup express and node
        app    = express()
        app.use app.router

        server = app.listen port
        io     = io.listen server
        require('./routes')(app, io)

        # socket.io
        # TODO Clean this up, move it somewhere else
        io.sockets.on 'connection', (socket) =>
            socket.on 'entered', (roomId, userJson, options={}) ->
                record = Record.create(options.recordJson) if options.recordJson

                # Get the requested room (or create it if it doesn't exist),
                # Create the user
                room = Room.find(roomId) || new Room(roomId, record: record)

                # Find or create the user
                user = User.find(userJson.id) || new User(userJson)

                # Connect the user and socket to the room
                socket.user = user
                socket.room = room

                user.join room
                socket.join room.id

                user.emitUpdate(io)

            #------------------------

            socket.on 'disconnect', ->
                user = socket.user
                room = socket.room

                if room
                    socket.leave room

                    if user
                        user.leave room if user
                        user.emitUpdate(io)

module.exports = Base
