_u      = require "underscore"
path    = require 'path'
express = require 'express'
io      = require('socket.io')

module.exports = class Core
    DefaultOptions:
        log:    null
        port:   8888
        
    constructor: (opts) ->
        @options     = _u.defaults opts||{}, @DefaultOptions
        connections = {}
        users       = {}

        colors = [
            '#FFBBF7', # pink
            '#DDCEFF', # purple
            "#A5DBEB", # blue
            "#B5FFC8" # green
        ]
        
        used_colors = []
                
        @app    = express()
        @app.use express.bodyParser()
        @server = @app.listen @options.port
        io     = io.listen @server

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
        io.sockets.on 'connection', (socket) ->
            console.log "connected: ", socket.id

            socket.on "queue_wait", (user_str) ->
                user = JSON.parse(user_str)
                socket.username = user.username
                connections[user.username] = socket

            socket.on 'entered', (user_str, object_str) ->
                object = JSON.parse(object_str)
                user = JSON.parse(user_str)
                socket.username = user.username
                connections[user.username] = socket

                user.color = colors[Math.floor(Math.random()*colors.length)]
                used_colors.push user.color
                colors.splice(colors.indexOf(user.color), 1)

                users[user.username] = user
                socket.join(object.id)
                socket.emit("load_viewers", users)
                socket.broadcast.emit("add_viewer", user)

            socket.on 'focus', (field_id) ->
                io.sockets.emit 'highlight_field', field_id, users[socket.username].color

            socket.on 'blur', (field_id) ->
                io.sockets.emit 'unhighlight_field', field_id

            socket.on 'disconnect', ->
                user = users[socket.username]
                if user
                    io.sockets.emit('remove_viewer', user)

                    used_colors.splice(used_colors.indexOf(user.color), 1)
                    colors.push user.color

                    delete users[socket.username]
                    delete connections[socket.username]
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
