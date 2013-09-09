
redis = require 'redis'


module.exports = (app) ->

  provider =
    getUserService: () ->
      # create a new client if there is none
      if not @redisClient?
        @redisClient = redis.createClient()

      UserService = require './service/user-service'
      new UserService(@redisClient)

    releaseResources: () ->
      if @redisClient?
        @redisClient.quit()
