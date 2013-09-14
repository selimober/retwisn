# Node Libraries
express = require 'express'
http = require 'http'
config = require 'yaml-config'
redis = require "redis"

app = express()

# Configuration
settings = config.readConfig require.resolve './conf/config.yaml'
app.set 'settings', settings

app.use express.bodyParser
app.use app.router

routes = require './conf/routes'
routes app

process.on 'SIGINT', ->
  require('./conf/provider').releaseResources()
  process.exit()

# run it
server = http.createServer app
server.listen settings.app.port


