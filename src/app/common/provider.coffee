redis = require 'redis-url'
config = require 'yaml-config'

module.exports = ( ->

  settings = config.readConfig require.resolve './config.yaml'

  provider =
    getUserService: ->
      @redisClient = @createRedisClient()

      UserService = require '../user/user-service'
      new UserService(@redisClient)

    getPostService: ->
      @redisClient = @createRedisClient()

      PostService = require '../post/post-service'
      new PostService(@redisClient)

    releaseResources: ->
      if @redisClient?
        @redisClient.quit()

    createRedisClient: ->
      # create a new client if there is none
      if not @redisClient?
        if process.env.REDISTOGO_URL?
          @redisClient = redis.connect process.env.REDISTOGO_URL
        else
          @redisClient = redis.createClient settings.redis.port, settings.redis.host
      else
        @redisClient

)()
