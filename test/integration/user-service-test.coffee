assert = require "assert"
sinon = require "sinon"
should = require "should"
UserService = require "../../service/user-service"
keys = require "../../model/data"

describe "UserService", ->

  before ->
    provider = require '../../conf/provider'
    @redis = provider.createRedisClient()
    @username = 'selim' + new Date / 1000
    @username2 = 'cem' + new Date / 1000
    @usernameUid = null

  describe "createUser", ->
    it 'should create a User with user id given a username and a password', (done) ->
      sut = new UserService(@redis)

      password = 's123'
      sut.createUser @username, password, (err, user) =>
        @usernameUid = user.uid
        user.should.have.property 'username', @username
        user.should.not.have.property 'password'
        should.exist user.uid
        should.not.exist err
        done()

    it 'should reject user creation if a user with same username already registered', (done) ->
      sut = new UserService(@redis)

      sut.createUser @username, 's123', (err, user) ->
        should.not.exist user
        err.should.be.an.instanceof Error
        done()

  describe 'fetchUserByUserName', ->
    it 'should return User give username', (done) ->
      sut = new UserService(@redis)

      sut.fetchUserByUserName @username, (err, user) ->
        user.should.have.property 'username', @username
        should.exist user.uid
        done()

  describe 'follow', ->
    it 'should add appropriate usernames to following and followers sets', (done) ->
      sut = new UserService @redis

      sut.createUser @username2, 'secret', (err, user) =>
        sut.follow @username, @username2, (err) =>
          should.not.exist err
          @redis.sismember keys.uid_followers(user.uid), @usernameUid, (err, response) =>
            response.should.be.ok
            @redis.sismember keys.uid_following(@usernameUid), user.uid, (err, response) ->
              response.should.be.ok
              done()



  after ->
    @redis.quit()