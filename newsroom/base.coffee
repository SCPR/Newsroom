_u      = require 'underscore'
path    = require 'path'
express = require 'express'
io      = require 'socket.io'

User       = require('./user')
Room       = require('./room')

class Base
    DefaultOptions:
        port:   8888

    constructor: (opts) ->
        @options     = _u.defaults opts||{}, @DefaultOptions

        # Setup express and node
        @app    = express()
        @app.use @app.router
        @server = @app.listen @options.port
        io      = io.listen @server
        require('./routes')(@app, User.connected)

                
        # socket.io
        # TODO Clean this up, move it somewhere else
        io.sockets.on 'connection', (socket) =>
            console.log "***got connection for", socket.id

            socket.on 'entered', (room_json, user_json, object_json="null") =>
                console.log "*** got enter for #{socket.id}"
                # Parse the information we were given
                roomInfo = JSON.parse(room_json)
                userInfo = JSON.parse(user_json)
                object   = JSON.parse(object_json)
                                
                # Create the user, and
                # Get the requested room (or create it if it doesn't exist)
                room = Room.all()[roomInfo.id] || Room.create(roomInfo)
                user = User.create socket, room.id, userInfo

                # Connect the user and socket to the room
                user.join room
                socket.join room.id
                
                # Now hand the events off to the Room object
                room.entered(socket, user, object)

            socket.on 'focus', (field_id) =>
                io.sockets.emit 'highlight_field', field_id, @users.connected[socket.id].color

            socket.on 'blur', (field_id) =>
                io.sockets.emit 'unhighlight_field', field_id

            socket.on 'disconnect', =>
                console.log "***got disconnect for", socket.id
                
                # If a user exists with this socket.id,
                # send the signal to remove this user
                if user = User.connected[socket.id]
                    io.sockets.emit('remove-user', user)
                    user.destroy()
                
                socket.leave socket.room

    #----------

module.exports = Base