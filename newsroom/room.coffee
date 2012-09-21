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

module.exports = class Room
    @_collection = {}
    
    #----------
    # Create a new Room object (subclassed)
    # and add it to Room._collection
    @create: (attributes) ->
        room = new Room[attributes.type](attributes)
        @_collection[room.id] = room

    #----------
    # Remove a room from Room._collection
    @destroy: (roomId) ->
        delete @_collection[roomId]
    
    #----------
    # Filter rooms by type
    @all: (type=null) ->
        if !type?
            return @_collection
            
        filtered = []
        _u.map @_collection, (room) ->
            if room.type is type
                filtered.push room
        filtered

    #----------
    # Get all users for a type of Room
    # Room.Active.users()
    @users: ->
        users = []
        _u.each @all(), (room) ->
            users = users.concat room.users
        users
        
    #--------------------------------
    
    constructor: (attributes) ->
        _u.each attributes, (value, attribute) =>
            @[attribute] = value

    connect: (user) ->
        @users.push user
        
    disconnect: (user) ->
        @users.splice @users.indexOf(user), 1
    
    destroy: ->
        Room.destroy @id

    #--------------
    # Room.Active
    #
    # An "Active" room is a room in which
    # there could be activity. It will publish
    # messages.
    # Examples: Edit pages
    #
    class @Active extends Room
        @all: ->
            super "Active"

        constructor: (attributes) ->
            @users = []
            super

        #--------------
        # Socket.io message responses
        entered: (socket, user, object) ->
            socket.emit("load-list", @users)
            socket.broadcast.to(@id).emit("new-user", user)
            socket.broadcast.to("dashboard").emit("new-user", user, object)


    #--------------
    # Room.Inactive
    #
    # An "Inactive" room is a room in which
    # there will not be activity. It only listens
    # for messages coming from Active rooms.
    # Examples: Edit pages
    #
    class @Inactive extends Room
        @all: ->
            super "Inactive"

        constructor: (attributes) ->
            @users = []
            super
            
        #--------------
        # Socket.io message responses
        entered: (socket, user, object) ->
            console.log "users are", Room.Active.users()
            socket.emit("load-list", Room.Active.users())
