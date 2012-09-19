_u      = require 'underscore'
path    = require 'path'
express = require 'express'
io      = require 'socket.io'

module.exports = class Core
    DefaultOptions:
        log:    null
        port:   8888
    
    Connections:  require "./connections/connections"
    Users:        require "./users/users"
    Rooms:        require "./rooms/rooms"

    constructor: (opts) ->
        @options     = _u.defaults opts||{}, @DefaultOptions
        @connections = new @Connections
        @users       = new @Users
        @rooms       = new @Rooms

        # Setup express and node
        @app    = express()
        @app.use express.bodyParser()
        @server = @app.listen @options.port
        io      = io.listen @server


        # Routing
        # TODO Clean this up, move it somewhere else
        @app.get '/', (req, res) ->
          res.send 404

        @app.post '/notify/:action/:to', (req, res) ->
          target = connections[req.params.to]
          if target
            connections[req.params.to].emit(req.params.action, req.body)
            res.send 200
          else
            res.send 404

        
        # socket.io
        # TODO Clean this up, move it somewhere else
        io.sockets.on 'connection', (socket) =>
            console.log "***got connection for", socket.id
            connection = @connections.add socket
            
            socket.on 'entered', (user_json, object_json) =>
                object = JSON.parse(object_json)
                user   = @users.connect connection, JSON.parse(user_json)
                room   = @rooms[object.obj_key]
                
                if !room?
                    room = @rooms.add object.obj_key
                
                user.join room
                socket.join room.id
                    
                # If this is an edit page
                if object.id?
                    users = room.users
                else
                    users = @rooms.users()
                
                socket.emit("load-list", users)
                socket.broadcast.to(room.id).emit("new-user", user)
                socket.broadcast.to("dashboard").emit("new-user", user)

            socket.on 'focus', (field_id) =>
                io.sockets.emit 'highlight_field', field_id, @users.connected[socket.id].color

            socket.on 'blur', (field_id) =>
                io.sockets.emit 'unhighlight_field', field_id

            socket.on 'disconnect', =>
                console.log "***got disconnect for", socket.id
                
                if user = @users.connected[socket.id]
                    io.sockets.emit('remove_viewer', user)
                    @users.colors.markAvailable(user.color)

                @users.disconnect(socket)
                @connections.remove(socket)
                
                socket.leave socket.room
        
    router: (req, res, next) ->
        @app.get '/', (req, res) ->
          res.send 404

        @app.post '/notify/:action/:to', (req, res) ->
          target = @connections[req.params.to]
          if target
            @connections[req.params.to].emit(req.params.action, req.body)
            res.send 200
          else
            res.send 404
        
    #----------
