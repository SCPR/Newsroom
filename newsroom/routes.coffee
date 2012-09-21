## Routes
#
# Route definitions for Express
#
module.exports = (app, users) ->
    app.get '/', (req, res) ->
      res.send 404

    app.post '/notify/:action/:to', (req, res) ->
      target = users[req.params.to]
      if target
        users[req.params.to].emit(req.params.action, req.body)
        res.send 200
      else
        res.send 404
