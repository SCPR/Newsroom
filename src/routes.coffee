## Routes
#
# Route definitions for Express
#
Room = require "./room"

module.exports = (app, io) ->
    app.get '/', (req, res) ->
      res.send 404

    app.post '/task/finished/:room', (request, response) ->
      rooms = Room.all()
      room  = rooms[request.params.room]
      
      if room
        io.sockets.in(room.id).emit("finished-task", request.body)
        response.send 200
      else
        response.send 404
