should = require('chai').should()
Base = require '../src/base'

describe "Base", ->
    it "is alive", ->
        Base.should.be.ok
