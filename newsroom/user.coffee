##
# User
#
# Populated via JSON passed in
#
# @connected is an Object of Users,
# with socket.id as the key and
# User object as the value.
#
_u = require 'underscore'
Colors = require('./colors')
Room = require('./room')

module.exports = class User
    @colors    = new Colors
    @connected = {}

    # Create a new user and add it
    @create: (socket, roomId, attributes) ->
        user = new User(socket.id, roomId, attributes)
        @connected[socket.id] = user
    
    # Destroy a User based on socketId
    @destroy: (socketId) ->
        user = @connected[socketId]
        room = user.room()
        user.leave room
        
        @colors.markAvailable user.color

        if _u.isEmpty user.room().users
            user.room().destroy()
            
        delete @connected[socketId]

    #-------------------------
    
    constructor: (@socketId, @roomId, attributes) ->
        @color = User.colors.pick()

        _u.each attributes, (value, attribute) =>
            @[attribute] = value
    
    # Join a Room
    join: (room) ->
        room.connect @

    # Leave a Rooom    
    leave: (room) ->
        room.disconnect @

    # Destroy this User
    destroy: ->
        User.destroy @socketId
    
    # Get the Room instance for this user
    room: ->
        Room.all()[@roomId]