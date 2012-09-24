##
# Record
#
# A simple representation of an object passed in
# to Newsroom.js. It doesn't necessarily have to
# be a database record, but it probably will be.
#
# It can be anything... this class just provides
# a means to interact with it.
#
# Attach it to a user so you can pass it back
# and forth between Client and Server-side
# without thinking about it.
#
# Don't use a collection here, because we don't
# want to be passing around potentially out-of-date
# data
#
class Record
    #---------------
    # Create a Record
    @create: (recordInfo) ->
        record = new Record(recordInfo)
    
    #---------------
    
    constructor: (attributes) ->
        for attribute, value of attributes
            @[attribute] = value

module.exports = Record
