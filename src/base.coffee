_u      = require 'underscore'
path    = require 'path'
express = require 'express'
io      = require 'socket.io'

User   = require('./user')
Room   = require('./room')
Record = require('./record')

class Base
    DefaultOptions:
        port:   8888

    constructor: (opts={}) ->
        @options = _u.defaults opts, @DefaultOptions
        
        # Setup express and node
        @app    = express()
        @app.use @app.router
        @server = @app.listen @options.port
        io      = io.listen @server
        require('./routes')(@app, io)

        
        # socket.io
        # TODO Clean this up, move it somewhere else
        io.sockets.on 'connection', (socket) =>
            console.log "***got connection for", socket.id

            socket.on 'entered', (roomId, userJson, options={}) ->
                # Parse the information we were given
                userInfo = JSON.parse(userJson)
                
                if options.recordJson
                    recordInfo = JSON.parse(options.recordJson)
                    record     = Record.create(recordInfo)

                # Get the requested room (or create it if it doesn't exist),
                # Create the user
                room   = Room.find(roomId) || new Room(roomId, record: record)
                
                # Find or create the user
                user = User.find(userInfo.id) || new User(userInfo)

                # Connect the user and socket to the room
                socket.user = user
                socket.room = room

                user.join room
                socket.join room.id
                
                io.sockets.in(room.id).emit("loadList", room.users) unless room.id is "dashboard"
                io.sockets.in("dashboard").emit("loadList", User.all())                
            
            #------------------------
            
            socket.on 'disconnect', ->
                console.log "***got disconnect for", socket.id

                user = socket.user
                room = socket.room
                
                user.leave room
                socket.leave room
                
                io.sockets.in(room.id).emit("loadList", room.users) unless room.id is "dashboard"
                io.sockets.in("dashboard").emit("loadList", User.all())

module.exports = Base
