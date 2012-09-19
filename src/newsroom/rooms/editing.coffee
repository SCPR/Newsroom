_u = require 'underscore'
require './room'

module.exports = class Editing extends Room
    constructor: (options) ->
        @options = _u.defaults options||{}, @DefaultOptions
