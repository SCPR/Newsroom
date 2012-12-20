## Routes
#
# Route definitions for Express
#
module.exports = (app, users) ->
    app.get '/', (req, res) ->
      res.send 404

    app.post '/task/finished/:user', (req, res) ->
      target = users[req.params.user]
      if target
        users[req.params.to].emit("finished", req.body)
        res.send 200
      else
        res.send 404
