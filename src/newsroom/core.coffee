_u      = require 'underscore'
path    = require 'path'
express = require 'express'
io      = require 'socket.io'

require './user'
require './connections'

module.exports = class Core
    DefaultOptions:
        log:    null
        port:   8888
    
    Connections:  require "./connections"
    Users:        require "./users"
    Colors:       require "./colors"
    
    constructor: (opts) ->
        @options     = _u.defaults opts||{}, @DefaultOptions
        @connections = new @Connections
        @users       = new @Users
        
        used_colors = []
        
        # Setup express and node
        @app    = express()
        @app.use express.bodyParser()
        @server = @app.listen @options.port
        io      = io.listen @server

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
        io.sockets.on 'connection', (socket) =>
            connection = @connections.add socket

            socket.on 'entered', (user_json, object_json) =>
                user = @users.connect connection, JSON.parse(user_json)
                
                socket.emit("load_viewers", @users.connected)
                socket.broadcast.emit("add_viewer", user)

            socket.on 'focus', (field_id) =>
                io.sockets.emit 'highlight_field', field_id, @users.connected[socket.id].color

            socket.on 'blur', (field_id) =>
                io.sockets.emit 'unhighlight_field', field_id

            socket.on 'disconnect', =>
                @users.disconnect(socket)
                @connections.remove(socket)
                
                if user = @users.connected[socket.id]
                    io.sockets.emit('remove_viewer', user)
                    @users.colors.markAvailable(user.color)
                
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
