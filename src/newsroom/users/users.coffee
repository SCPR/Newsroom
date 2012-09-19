##
# Users
# A collection of User objects
# @connected - an object of all connected users
#
_u = require 'underscore'

module.exports = class Users extends Object
    User: require "./user"
    Colors: require "./colors"
    
    constructor: (options) ->
        @options = _u.defaults options||{}, @DefaultOptions
        @colors = new @Colors
        @connected = {}
    
    connect: (connection, json) ->
        # Create a new user
        user = new @User(json, color: @colors.pick())
        @connected[connection.socket.id] = user
        
    disconnect: (socket) ->
        delete @connected[socket.id]
