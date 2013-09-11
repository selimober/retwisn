assert = require "assert"
sinon = require "sinon"
should = require "should"

UserController = require '../../controller/user-controller'

describe 'UserController', ->

  beforeEach ->
    @res =
      render: sinon.spy()
      redirect: sinon.spy()
      status: => @res

  describe 'createUser', ->
    it 'should render to /home with error if username empty', ->
      # Arrange
      req =
        param:
          password: 'xcxc'
          username: ''

      # Act
      sut = new UserController
      sut.createUser req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/home', sinon.match {status: 'ERROR'}

    it 'should render to /home with error if password empty', ->
      # Arrange
      req =
        param:
          password: ''
          username: 'user'

      # Act
      sut = new UserController
      sut.createUser req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/home', sinon.match {status: 'ERROR'}

    it 'should render to /home with success when called with username and password', ->

      # Arange
      userService =
        createUser: (username, password, callback) ->
          callback null, {username: username, password: password}

      req =
        param:
          password: 'secret'
          username: 'user'

      # Act
      sut = new UserController userService
      sut.createUser req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/home', sinon.match {status: 'OK'}

  describe 'login', ->
    it 'should render to /home with error if username or password is empty', ->
      # Arrange
      req =
        param:
          password: 'secret'
          username: ''

      # Act
      sut = new UserController
      sut.login req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/home', sinon.match {status: 'ERROR'}

      # Arrange
      req =
        param:
          password: ''
          username: 'user'

      # Act
      sut.login req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/home', sinon.match {status: 'ERROR'}

    it 'should render to /home with error if username / password don\'t match', ->
      # Arange
      req =
        param:
          password: 'secret'
          username: 'user'

      userService =
        login: (username, password, callback) ->
          callback new Error, null

      # Act
      sut = new UserController userService
      sut.login req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/home', sinon.match {status: 'ERROR'}

    it 'should redirect to /timeline and set the auth cookie to authSecret if username / password match', ->
      # Arange
      req =
        param:
          password: 'secret'
          username: 'user'
        app:
          get: ->
            app:
              domain: 'localhost'
              authCookieName: 'auth'
      @res.cookie = sinon.spy()

      authSecret = 'zxcasdq12dsadsa'

      userService =
        login: (username, password, callback) ->
          callback null, authSecret

      # Act
      sut = new UserController userService
      sut.login req, @res

      # Assert
      sinon.assert.calledWith @res.cookie, 'auth', authSecret
      sinon.assert.calledWith @res.redirect, '/timeline'

  describe 'follow', ->
    it 'should redirect to /timeline given an existing username to follow', ->
      # Arrange
      req =
        param:
          followedUserName: 'cem'
        loggedInUsername: 'selim'

      userService =
        follow: (user1, user2, callback) ->
          callback null

      # Act
      sut = new UserController userService
      sut.follow req, @res

      # Assert
      sinon.assert.calledWith @res.redirect, '/timeline'

    it 'should render /timeline with error given an empty following and followed username', ->
      # Arrange
      req =
        param: {}

      # Act
      sut = new UserController
      sut.follow req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/timeline', sinon.match {status: 'ERROR'}

    it 'should render /timeline with error given an unexisting username', ->
      # Arrange
      req =
        param:
          followedUserName: 'cem'
        loggedInUsername: 'selim'

      userService =
        follow: (user1, user2, callback) ->
          callback new Error

      # Act
      sut = new UserController userService
      sut.follow req, @res

      # Assert
      sinon.assert.calledWith @res.render, '/timeline', sinon.match {status: 'ERROR'}
