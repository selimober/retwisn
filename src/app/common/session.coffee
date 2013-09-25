url = require 'url'
express = require 'express'
RedisStore = require('connect-redis')(express)
flash = require 'connect-flash'

module.exports = (app) ->

  redisStore = {}
  config = app.get 'config'

  if process.env.REDISTOGO_URL?
    redisUrl = url.parse process.env.REDISTOGO_URL
    redisAuth = redisUrl.auth.split(':')
    redisStore = new RedisStore({
      host: redisUrl.hostname
      port: redisUrl?.port
      db: redisAuth?[0]
      pass: redisAuth?[1]
      prefix: config.redis.sessionPrefix
    })
  else
    redisStore = new RedisStore({
      host: config.redis.host
      port: config.redis.port
      prefix: config.redis.sessionPrefix
    })

  app.use express.session {
    store: redisStore
    secret: config.redis.sessionSecret
    cookie:
      maxAge: 60 * 10 * 1000
  }

  app.use flash()

  app.use (req, res, next) ->
    req.session.resetCounter = Date.now()
    path = req.path
    if path is "" or path is "/" or path is "/login" or path is "/signup"
      next()
    else
      if req.session.username?
        next()
      else
        req.flash 'error', 'Session expired or never authenticated'
        res.redirect '/'


  app.use (req, res, next) ->
    res.locals.session = req.session
    next()

