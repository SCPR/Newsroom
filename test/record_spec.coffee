should = require('chai').should()
Record = require '../src/user'

describe "Record", ->
    it "is alive", ->
        Record.should.be.ok
