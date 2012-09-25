should = require('chai').should()
Room = require '../src/user'

describe "Room", ->
    it "is alive", ->
        Room.should.be.ok
