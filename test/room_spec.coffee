should = require('chai').should()
Room = require '../src/room'

describe "Room", ->
    it "is alive", ->
        Room.should.be.ok
