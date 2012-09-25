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

    constructor: (opts) ->
        @options     = _u.defaults opts||{}, @DefaultOptions

        # Setup express and node
        @app    = express()
        @app.use @app.router
        @server = @app.listen @options.port
        io      = io.listen @server
        require('./routes')(@app, User.all())

                
        # socket.io
        # TODO Clean this up, move it somewhere else
        io.sockets.on 'connection', (socket) =>
            console.log "***got connection for", socket.id

            socket.on 'entered', (room_json, user_json, record_json="null") ->
                # Parse the information we were given
                roomInfo   = JSON.parse(room_json)
                userInfo   = JSON.parse(user_json)
                recordInfo = JSON.parse(record_json)

                # Get the requested room (or create it if it doesn't exist),                                
                # Create a record if it was passed in
                # Create the user
                record = Record.create(recordInfo) if recordInfo?
                room   = Room.find(roomInfo.id) || Room.create(roomInfo, record: record)
                user   = User.create socket, room.id, userInfo

                # Connect the user and socket to the room
                user.join room
                socket.join room.id
                
                # Now hand the events off to the Room object
                room.entered(socket, user, record)


            socket.on 'fieldFocus', (fieldId) ->
                if user = User.find socket.id
                    room = Room.find user.roomId
                    room.fieldFocus io, socket, fieldId, user


            socket.on 'fieldBlur', (fieldId) ->
                if user = User.find socket.id
                    room = Room.find user.roomId
                    room.fieldBlur io, socket, fieldId, user
                

            socket.on 'disconnect', ->
                console.log "***got disconnect for", socket.id
                
                # If a user exists with this socket.id,
                # send the signal to remove this user
                if user = User.find(socket.id)
                    room = Room.find user.roomId
                    io.sockets.emit('removeUser', user)
                    user.destroy()
                
                socket.leave socket.room

    #----------

module.exports = Base
