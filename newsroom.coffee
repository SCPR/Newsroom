nconf = require("nconf")
nconf.env().argv()

# add in config file
nconf.file( { file: nconf.get("config") || nconf.get("CONFIG") || "/etc/newsroom.conf" } )

Base = require('./src/base')
newsroom = new Base nconf.get("./newsroom")
