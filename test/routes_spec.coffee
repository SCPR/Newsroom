should = require('chai').should()
Routes = require '../src/routes'

describe "Routes", ->
    it "is alive", ->
        Routes.should.be.ok
