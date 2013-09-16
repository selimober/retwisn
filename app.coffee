# Node Libraries
express = require 'express'
config = require 'yaml-config'
redis = require "redis"

app = express()

# Configuration
settings = config.readConfig require.resolve './conf/config.yaml'
app.set 'settings', settings
app.set 'views', './views'
app.set 'view engine', 'jade';

app.use (req, res, next) ->
  console.log('%s %s', req.method, req.url)
  next()

app.use express.json()
app.use (req, res, next) ->
app.use app.router

routes = require './conf/routes'
routes app

process.on 'SIGINT', ->
  require('./conf/provider').releaseResources()
  process.exit()

# run it
app.listen settings.app.port, ->
  console.log('App started on port ' + settings.app.port)


