_u = require 'underscore'

module.exports = class Connections extends Object
    Connection: require "./connection"
    
    constructor: (options) ->
        @options = _u.defaults options||{}, @DefaultOptions
        
    add: (socket) ->
        @[socket.id] = new @Connection(socket)

    remove: (socket) ->
        delete @[socket.id]
