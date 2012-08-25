Newsroom = require("./src/newsroom/core")
nconf = require("nconf")

nconf.env().argv()

# add in config file
nconf.file( { file: nconf.get("config") || nconf.get("CONFIG") || "/etc/newsroom.conf" } )

# -- launch our core -- #

core = new Newsroom nconf.get("newsroom")
