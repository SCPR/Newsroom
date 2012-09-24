##
# Colors
#
# Pretty, pretty colors.
#
#
_u = require 'underscore'

class Colors
    constructor: ->
        # These pastels were randomly generated
        # at some point.
        @available = [
            "#c0859f"
            "#8aaab0"
            "#91c68d"
            "#be9096"
            "#cc8296"
            "#8892ca"
            "#88a7b5"
            "#80c4a0"
            "#968fbf"
            "#8488d8"
            "#d19083"
            "#83adb4"
            "#c28c96"
            "#9c9aae"
            "#98a8a4"
            "#b08fa5"
            "#89bd9e"
            "#9b90b9"
            "#9488c8"
            "#90c68e"
        ]
        
        @in_use = []

    #-------------
    # Choose an available color
    pick: ->
        color = @random()
        @_switch(@available, @in_use, color)
        color

    #-------------
    # Mark a color as "available"
    markAvailable: (color) ->
        @_switch(@in_use, @available, color)
        @available

    #-------------
    # "Random" color from available colors
    random: ->
        @available[Math.floor(Math.random()*@available.length)]

    #-------------
    # Switch a color from available to in_use,
    # or reverse
    _switch: (from, to, color) ->
        color = from.splice(from.indexOf(color), 1)[0]
        to.push color

module.exports = Colors
