# Node Libraries
express = require 'express'
http = require 'http'
config = require 'yaml-config'
redis = require "redis"

# Configuration
settings = config.readConfig require.resolve './conf/config.yaml'

app = express()

app.use app.router

routes = require './conf/routes'
routes app

process.on 'SIGINT', ->
  require('./provider')().releaseResources()
  process.exit()

http.createServer(app).listen(3000)


