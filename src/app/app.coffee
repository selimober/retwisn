# Node Libraries
express = require 'express'
config = require 'yaml-config'
redis = require "redis"
path = require 'path'
RedisStore = require('connect-redis')(express)
session = require './common/session'
flash = require 'connect-flash'
app = express()

# Configuration
settings = config.readConfig require.resolve './common/config.yaml'
app.set 'settings', settings
app.set 'views', './views'
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
app.use express.session {
  store: new RedisStore({
    host: settings.redis.host
    port: settings.redis.port
    prefix: settings.redis.sessionPrefix
  }),
  secret: settings.redis.sessionSecret,
  cookie:
    maxAge: 60 * 10 * 1000
}
app.use flash()
app.use session
app.use (req, res, next) ->
  res.locals.session = req.session
  next()

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
app.listen settings.app.port, ->
  console.log('App started on port ' + settings.app.port)


