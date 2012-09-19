_u = require 'underscore'

module.exports = class User    
    constructor: (json, options) ->
        @options = _u.defaults options||{}, @DefaultOptions
        @color = @options.color

        _u.each json, (value, attribute) =>
            @[attribute] = value
