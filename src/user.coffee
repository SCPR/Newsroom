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
    # Destroy a User based on id
    # Removes them from all rooms and 
    # will also destroy a room if it 
    # is empty
    @destroy: (id) ->
        user = User.find(id)
        
        # Leave the rooms
        for room in user.rooms()
            user.leave room
            
        delete @_collection[id]

    #-------------------------
    
    constructor: (attributes, options={}) ->
        @roomIds = []
        @records = []
        
        for attribute, value of attributes
            @[attribute] = value
        
        User._collection[@id] = @
    
    #-------------
    # Join a Room
    join: (room) ->
        @roomIds.push room.id
        @records.push room.record if room.record?
        room.connect @

    #-------------
    # Leave a Room
    # If this user isn't in any rooms anymore, 
    # get rid of the user
    leave: (room) ->
        @roomIds.splice @roomIds.indexOf(room.id), 1
        
        if room.record?
            @records.splice @records.indexOf(room.record), 1
        
        @destroy() if _u.isEmpty @roomIds
        room.disconnect @
        
    #-------------
    # Destroy this User completely
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
