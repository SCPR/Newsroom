_u = require 'underscore'

module.exports = class Colors
    constructor: ->
        @available = []
        @used      = []
        
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green
        @available.push '#FFBBF7' #pink
        @available.push '#DDCEFF' #purple
        @available.push "#A5DBEB" #blue
        @available.push '#B5FFC8' #green

    pick: ->
        color = @random()
        @_switchArray(@used, @available, color)
        color
        
    markAvailable: (color) ->
        @_switchArray(@available, @used, color)
        @available

    random: ->
        @available[Math.floor(Math.random()*@available.length)]
    
    _switchArray: (from, to, color) ->
        to.concat from.splice(from.indexOf(color), 1)
