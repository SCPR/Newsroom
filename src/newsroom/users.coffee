_u = require 'underscore'

module.exports = class Users extends Object
    User: require "./user"
    Colors: require "./colors"
    
    constructor: (options) ->
        @options = _u.defaults options||{}, @DefaultOptions
        @colors = new @Colors
        @connected = {}
        
    connect: (connection, json) ->
        @connected[connection.socket.id] = new @User(json, color: @colors.pick())

    disconnect: (socket) ->
        delete @connected[socket.id]
