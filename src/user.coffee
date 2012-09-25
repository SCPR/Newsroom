##
# User
#
# Populated via JSON passed in
#
# @_collection is an Object of Users,
# with socket.id as the key and
# User object as the value.
#
_u = require 'underscore'
Room = require('./room')

class User
    @_collection = {}

    #-------------
    # Return all connected users
    @all: ->
        @_collection
        
    #-------------
    # Find a user by socket ID 
    @find: (socketId) ->
        @_collection[socketId]
        
    #-------------
    # Create a new user and add it
    @create: (socket, roomId, attributes, options) ->
        user = new User(socket.id, roomId, attributes, options)
        @_collection[socket.id] = user
    
    #-------------
    # Destroy a User based on socketId
    @destroy: (socketId) ->
        user = User.find(socketId)
        room = user.room()
        user.leave room
        
        room.colors.markAvailable user.color

        if _u.isEmpty user.room().users
            user.room().destroy()
            
        delete @_collection[socketId]

    #-------------------------
    
    constructor: (@socketId, @roomId, attributes, options) ->
        room    = Room.find @roomId
        @color  = room.colors.pick()
        
        for attribute, value of attributes
            @[attribute] = value
    
    #-------------
    # Join a Room
    join: (room) ->
        @record = room.record
        room.connect @

    #-------------
    # Leave a Rooom    
    leave: (room) ->
        @record = null
        room.disconnect @

    #-------------
    # Destroy this User
    destroy: ->
        User.destroy @socketId
    
    #-------------
    # Get the Room instance for this user
    room: ->
        Room.find @roomId

module.exports = User
