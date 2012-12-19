##
# Room
#
# An object representation of a socket.io room namespace
# Holds a list of connected users
#
# This is an abstract class and shouldn't be
# instantiated directly.
#
_u = require 'underscore'

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
    # Create a new Room object
    # and add it to @_collection
    @create: (args...) ->
        new Room(args...)

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
        
    disconnect: (user) ->
        @users.splice @users.indexOf(user), 1
    
    destroy: ->
        Room.destroy @id

    #--------------
    # Socket.io message responses
    # entered: When a user enters a room
    entered: (socket, user, record) ->
        socket.emit("loadList", @users)
        socket.broadcast.to(@id).emit("newUser", user)
        socket.broadcast.to("dashboard").emit("newUser", user)

module.exports = Room
