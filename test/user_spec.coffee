should = require('chai').should()
User = require '../src/user'

describe "User", ->
    it "is alive", ->
        User.should.be.ok
