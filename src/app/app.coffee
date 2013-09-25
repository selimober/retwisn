# Node Libraries
express = require 'express'
config = require 'yaml-config'
path = require 'path'
session = require './common/session'
app = express()

# Configuration
settings = config.readConfig require.resolve './common/config.yaml'
app.set 'config', settings

# 'app/views' instead of './views' because we start the app as 'node app/app.js'
app.set 'views', 'app/views'
app.set 'view engine', 'jade'

# Simple logger, consider Winston for serious business
app.use (req, res, next) ->
  console.log('%s %s', req.method, req.url)
  next()

# Send statics
app.use '/assets/', express.static(path.join(__dirname, '../public'))

# Parse POST and fileUploads queries
app.use express.bodyParser()

# Session Support
app.use express.cookieParser()
session(app)

# Router
app.use app.router
routes = require './common/routes'
routes app

# Development configuration
app.configure 'development', ->
  app.use express.errorHandler()
  app.locals.pretty = true

process.on 'SIGINT', ->
  require('./common/provider').releaseResources()
  process.exit()

# Run it
port = process.env.PORT || settings.app.port
app.listen port, ->
  console.log('App started on port ' + port)


