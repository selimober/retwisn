assert = require "assert"
sinon = require "sinon"
should = require "should"
PostService = require "../../service/post-service"
keys = require "../../model/data"

describe "PostService", ->

  before ->
    provider = require '../../conf/provider'
    @redis = provider.createRedisClient()
    @user1Name = 'selim' + new Date().getTime()
    @password = '1234'
    @user2Name = 'cem' + new Date().getTime()
    @user1Uid = null

  describe 'post', ->
    it 'should save the message', (done) ->

      username = 'selim'
      message = 'Test message'

      sut = new PostService @redis
      sut.post username, message, (err, pid) ->
        should.not.exists err
        pid.should.exists
        done()

    it.skip 'should add post to the global timeline', (done) ->

    it.skip 'should add post to author\'s timeline', (done) ->

    it.skip 'should add the post to user\'s followers\' timeline', (done) ->
