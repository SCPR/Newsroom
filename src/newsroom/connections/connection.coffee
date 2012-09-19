_u = require 'underscore'

module.exports = class Connection
    constructor: (@socket, options) ->
        @options = _u.defaults options||{}, @DefaultOptions
