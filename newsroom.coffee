nconf = require("nconf")
nconf.env().argv()

# Add config file
nconf.file(file: nconf.get("config"))

Base = require('./src/base')
newsroom = new Base nconf.get("newsroom")
