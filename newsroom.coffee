nconf = require("nconf")
nconf.env().argv()

# Add config file
nconf.file(file: nconf.get("config") || "config.json")

Base = require('./src/base')
newsroom = new Base nconf.get("newsroom")
