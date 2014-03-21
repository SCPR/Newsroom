##
# Room
#
# An object representation of a socket.io room namespace
# Holds a list of connected users
#
# This is an abstract class and shouldn't be
# instantiated directly.
#
_u   = require 'underscore'
User = require './user'

class Room
    @_collection = {}

    #----------
    # The collection
    @all: ->
        @_collection

    #----------
    # Find a room from ID
    @find: (id) ->
        @_collection[id]

    #----------
    # Remove a room from Room._collection
    @destroy: (id) ->
        room = Room.find(id)

        for user in room.users
            user.leave room

        delete @_collection[id]

    #--------------------------------

    constructor: (@id, options={}) ->
        @users = []
        @record = options.record if options.record?
        Room._collection[@id] = @

    connect: (user) ->
        @users.push user

    # Disconnect a user, destroy this room
    # if the users are empty
    disconnect: (user) ->
        @users.splice @users.indexOf(user), 1
        @destroy() if _u.isEmpty(@users)

    destroy: ->
        Room.destroy @id

module.exports = Room
