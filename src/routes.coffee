## Routes
#
# Route definitions for Express
#
Room = require "./room"

module.exports = (app, io) ->
    app.get '/', (req, res) ->
        res.send 404

    app.post '/task/finished/:room', (req, res) ->
        rooms = Room.all()
        room  = rooms[req.params.room]

        if room
            io.sockets.in(room.id).emit("finished-task", req.query)
            res.send(200, { status: "Success" })
        else
            res.send(404, { status: "Not Found" })
