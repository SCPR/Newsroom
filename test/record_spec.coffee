should = require('chai').should()
Record = require '../src/record'

describe "Record", ->
    it "is alive", ->
        Record.should.be.ok
