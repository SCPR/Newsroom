nconf = require("nconf")
nconf.env().argv()

Base = require('./src/base')
new Base(nconf.get("http-port") || 8888)
