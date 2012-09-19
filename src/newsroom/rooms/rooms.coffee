##
# Rooms
# A collection of rooms
#
_u = require 'underscore'

module.exports = class Rooms extends Object
    Room: require "./room"
    
    constructor: (options) ->
        @options = _u.defaults options||{}, @DefaultOptions

    add: (id) ->
        @[id] = new @Room(id)

    users: ->
        users = {}
        _u.each @, (room) ->
            _u.each room.users, (user) ->
                users[user.id] = user
        users
