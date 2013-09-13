assert = require "assert"
sinon = require "sinon"
should = require "should"
UserService = require "../../service/user-service"
keys = require "../../model/data"

describe "UserService", ->

  before ->
    provider = require '../../conf/provider'
    @redis = provider.createRedisClient()
    @user1Name = 'selim' + new Date().getMilliseconds()
    @password = '1234'
    @user2Name = 'cem' + new Date().getMilliseconds()
    @user1Uid = null

  describe "createUser", ->
    it 'should create a User with user id given a username and a password', (done) ->
      sut = new UserService(@redis)

      sut.createUser @user1Name, @password, (err, user) =>
        @user1Uid = user.uid
        user.should.have.property 'username', @user1Name
        user.should.not.have.property 'password'
        should.exist user.uid
        should.not.exist err
        done()

    it 'should reject user creation if a user with same username already registered', (done) ->
      sut = new UserService(@redis)

      sut.createUser @user1Name, @password, (err, user) ->
        should.not.exist user
        err.should.be.an.instanceof Error
        done()

  describe 'fetchUserByUserName', ->
    it 'should return User give username', (done) ->
      sut = new UserService(@redis)

      sut.fetchUserByUserName @user1Name, (err, user) ->
        user.should.have.property 'username', @user1Name
        should.exist user.uid
        done()

  describe 'follow', ->
    it 'should add appropriate usernames to following and followers sets', (done) ->
      sut = new UserService @redis

      sut.createUser @user2Name, @password, (err, user) =>
        sut.follow @user1Name, @user2Name, (err) =>
          should.not.exist err
          @redis.sismember keys.uid_followers(user.uid), @user1Uid, (err, response) =>
            response.should.be.ok
            @redis.sismember keys.uid_following(@user1Uid), user.uid, (err, response) ->
              response.should.be.ok
              done()

  describe 'login', ->
    it 'should add or overrite existing authorization information', (done) ->

      # Arrange
      sut = new UserService @redis

      check = (err, authKey) =>
        should.not.exist err
        @redis.get keys.uid_auth(@user1Uid),  (err, key) =>
          key.should.be.equal authKey
          @redis.get keys.auth_uid(authKey), (err, uid) =>
            uid.should.be.equal @user1Uid
            done()

      # Act & Assert
      sut.login @user1Name, @password, 600000, check


  after ->
    @redis.quit()