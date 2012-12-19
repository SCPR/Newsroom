##
# User
#
# Populated via JSON passed in
#
# @_collection is an Object of Users,
# with socket.id as the key and
# User object as the value.
#
_u   = require 'underscore'
Room = require('./room')

class User
    @_collection = {}
    
    #-------------
    # Return all connected users
    @all: ->
        @_collection
        
    #-------------
    # Find a user by ID
    @find: (id) ->
        @_collection[id]
        
    #-------------
    # Create a new user
    @create: (args...) ->
        new User(args...)
    
    #-------------
    # Destroy a User based on socketId
    @destroy: (id) ->
        user = User.find(id)
        
        # Leave the rooms
        for room in user.rooms()
            user.leave room

            # If the room is empty, destroy it
            room.destroy() if _u.isEmpty room.users
            
        delete @_collection[id]

    #-------------------------
    
    constructor: (attributes, options={}) ->
        @roomIds   = []
        @socketIds = []
        
        @addSocket options.socket if options.socket?
        @join      options.room   if options.room?
        
        for attribute, value of attributes
            @[attribute] = value
        
        User._collection[@id] = @
    
    #-------------
    # Add to this user's socket collection
    addSocket: (socket) ->
        @socketIds.push socket.id
        
    #-------------
    # Join a Room
    join: (room) ->
        @roomIds.push room.id
        room.connect @

    #-------------
    # Leave a Room
    leave: (room) ->
        @roomIds.splice @roomIds.indexOf(room.id), 1
        room.disconnect @

    #-------------
    # Destroy this User
    destroy: ->
        User.destroy @id
    
    #-------------
    # Get the Rooms this user in
    rooms: ->
        rooms = []
        for roomId in @roomIds
            rooms.push room if room = Room.find roomId
        rooms
        
module.exports = User
