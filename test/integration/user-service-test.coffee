assert = require "assert"
sinon = require "sinon"
should = require "should"
UserService = require "../../service/user-service"

describe "UserService", ->

  before ->
    provider = require '../../conf/provider'
    @redis = provider.createRedisClient()
    @username = 'selim' + new Date / 1000

  describe "createUser", ->
    it 'should create a User with user id given a username and a password', (done) ->
      sut = new UserService(@redis)

      password = 's123'
      sut.createUser @username, password, (err, user) ->
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

  after ->
    @redis.quit()