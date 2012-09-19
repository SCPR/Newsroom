##
# Room
# An object representation of a socket.io room namespace
# Holds a list of connected users
#
_u = require 'underscore'

module.exports = class Room
    Users: require "../users/users"
    
    constructor: (@id, options) ->
        @options = _u.defaults options||{}, @DefaultOptions
        @users = {}
