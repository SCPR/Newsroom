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
Colors = require('./colors')

class Room
    @_collection = {}

    #----------
    # Find a room from ID
    @find: (id) ->
        @all()[id]
        
    #----------
    # Create a new Room object (subclassed)
    # and add it to Room._collection
    @create: (attributes, options) ->
        room = new Room[attributes.type](attributes, options)
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
        for room in @all()
            users = users.concat room.users
        users
        
    #--------------------------------

    # Each room has a set of colors
    colors: new Colors
    
    constructor: (attributes, options) ->
        @record = options.record if options.record?
        
        for attribute, value of attributes
            @[attribute] = value

    connect: (user) ->
        @users.push user
        
    disconnect: (user) ->
        @users.splice @users.indexOf(user), 1
    
    destroy: ->
        Room.destroy @id

    fieldFocus: (socket, fieldId, user) ->
        true
        
    fieldBlur: (socket, fieldId, user) ->
        true
        
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

        constructor: (attributes, options) ->
            @users = []
            super

        #--------------
        # Socket.io message responses
        entered: (socket, user, record) ->
            socket.emit("loadList", @users)
            socket.broadcast.to(@id).emit("newUser", user)
            socket.broadcast.to("dashboard").emit("newUser", user)
        
        fieldFocus: (socket, fieldId, user) ->
            socket.emit('fieldFocus', fieldId, user)

        fieldBlur: (socket, fieldId, user) ->
            socket.emit('fieldBlur', fieldId, user)
            
    #--------------
    # Room.Inactive
    #
    # An "Inactive" room is a room in which
    # there will not be activity. It only listens
    # for messages coming from Active rooms.
    # Examples: Index pages
    #
    class @Inactive extends Room
        @all: ->
            super "Inactive"

        constructor: (attributes, options) ->
            @users = []
            super
            
        #--------------
        # Socket.io message responses
        entered: (socket, user, object) ->
            users = Room.Active.users()
            socket.emit("loadList", users)

module.exports = Room
